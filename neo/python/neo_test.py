#!/usr/bin/env python3
###
# pip install neo4j-driver

from neo4j.v1 import GraphDatabase, basic_auth

driver = GraphDatabase.driver(
	"bolt://54.236.44.131:33154",
	auth=basic_auth("neo4j", "hand-pecks-refrigerators"))
session = driver.session()

# Who are the most important characters in the first book?
cypher_query = """
CALL algo.betweenness.stream('Character', 'INTERACTS1', {direction: 'BOTH'})
YIELD nodeId, centrality
MATCH (c:Character) WHERE ID(c) = nodeId
RETURN c.name AS character, centrality
ORDER BY centrality DESC
LIMIT $limit
"""

results = session.run(cypher_query,
  parameters={"limit": 10})

for record in results:
  print(record['character'], record['centrality'])
