import requests

for i in range(1,73):
  with open(f'data/data_{i}.csv', 'w') as f:
    r = requests.get(f"https://www.electionresults.govt.nz/electionresults_2020/statistics/csv/split-votes-electorate-{i}.csv")
    r.encoding = 'utf-8'
    f.write(r.text)
