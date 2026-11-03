from pathlib import Path
import pandas as pd

ROOT=Path(__file__).resolve().parents[1]
RAW=ROOT/"data"/"raw"
OUT=ROOT/"data"/"processed"
OUT.mkdir(parents=True,exist_ok=True)

routes=pd.read_csv(RAW/"routes.csv")
trips=pd.read_csv(RAW/"trips.csv",parse_dates=["scheduled_departure","actual_arrival"])
pax=pd.read_csv(RAW/"passenger_counts.csv")
inc=pd.read_csv(RAW/"incidents.csv")

# Validate primary keys and relationships before transforming.
assert routes.route_id.is_unique
assert trips.trip_id.is_unique
assert trips.route_id.isin(routes.route_id).all()
assert pax.trip_id.isin(trips.trip_id).all()

routes["route_code"]=routes.route_code.astype(str).str.strip().str.upper()
trips["service_status"]=trips.service_status.astype(str).str.strip().str.title()
trips["actual_duration_minutes"]=(trips.actual_arrival-trips.scheduled_departure).dt.total_seconds()/60
trips["delay_minutes"]=trips.actual_duration_minutes-trips.scheduled_duration_minutes
trips.loc[trips.service_status=="Cancelled","delay_minutes"]=pd.NA
trips["on_time_flag"]=((trips.service_status=="Operated")&(trips.delay_minutes<=5)).astype(int)

pax_total=pax.groupby("trip_id",as_index=False).passenger_count.sum()
out=trips.merge(routes[["route_id","route_code","route_name"]],on="route_id",how="left")
out=out.merge(pax_total,on="trip_id",how="left")
out["passenger_count"]=out.passenger_count.fillna(0).astype(int)
out["service_date"]=out.scheduled_departure.dt.date
out["scheduled_hour"]=out.scheduled_departure.dt.hour
out.to_csv(OUT/"trip_performance.csv",index=False)
routes.to_csv(OUT/"routes_clean.csv",index=False)
inc.to_csv(OUT/"incidents_clean.csv",index=False)
print("ETL complete. Rows:",len(out))
print("Cancelled:",(out.service_status=="Cancelled").sum())
print("Operated:",(out.service_status=="Operated").sum())
