import csv

import requests
from bs4 import BeautifulSoup
from datetime import datetime

electorate_observations = []


def num_remove_comma(s: str, type_of_n=int):
    if s is not None and len(s):
        return type_of_n(s.replace(",", "").replace('%', ''))
    else:
        return None

def get_electorate_details(id):
    p = requests.get(f'https://www.electionresults.govt.nz/electionresults_2020/electorate-details-{str(id).zfill(2)}.html')
    soup = BeautifulSoup(p.content, 'html.parser')

    print(id)
    electorate = soup.select_one('.page-title h2').string.replace(' - Official Result', '')

    electorate_details = soup.find(id='electorate_details_table').find('tr')
    total_votes = num_remove_comma(electorate_details.find_all('td')[1].string)
    prop_counted = num_remove_comma(electorate_details.find_all('td')[2].string, type_of_n=float)

    contesting = soup.find(id='partyCandidatesResultsTable').find_all('tr')[1:-2]

    for c in contesting:
        candidate = c.find_all('td')[0]
        party = c.find_all('td')[1]

        candidate_name = candidate.select('span')[0].string
        candidate_vote = num_remove_comma(candidate.select_one('span.float-right').string)

        party_name = party.select('span')[0].string
        party_vote = num_remove_comma(party.select_one('span.float-right').string)

        yield {
            'electorate': electorate,
            'party': party_name,
            'party_vote': party_vote,
            'candidate': candidate_name,
            'candidate_vote': candidate_vote,
            'votes_counted': prop_counted,
            'total_votes': total_votes,
        }


for id in range(1, 73):
    electorate_observations.extend(list(get_electorate_details(id)))

with open(f'observations_{datetime.today().strftime("%Y-%m-%d")}.csv', 'w+') as f:
    writer = csv.DictWriter(f, fieldnames=electorate_observations[0].keys())
    writer.writeheader()
    writer.writerows(electorate_observations)
