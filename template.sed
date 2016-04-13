# sed -f template.sed article.md


/<GRAPH0>/ {
  r graph0
  d
}
/<GRAPH1>/ {
  r graph1
  d
}

/<GRAPH2>/ {
  r graph2
  d
}

/<GRAPH3>/ {
  r graph3
  d
}
