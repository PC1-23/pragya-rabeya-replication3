import csv
from collections import defaultdict
import datetime

latest = defaultdict(int)
with open('../datasets/coverage.csv') as f:
    reader = csv.DictReader(f)
    for row in reader:
        repo = row['repo']
        try:
            ts = int(row['timestamp'])
            if ts > latest[repo]:
                latest[repo] = ts
        except:
            pass

with open('../datasets/latest_dates.csv', 'w') as out:
    out.write('project,latest_date_in_dataset\n')
    for repo, ts in sorted(latest.items()):
        date = datetime.datetime.fromtimestamp(ts, datetime.UTC).strftime('%Y-%m-%d')
        print(f'{repo}: {date}')
        out.write(f'{repo},{date}\n')

print("\nSaved to datasets/latest_dates.csv")