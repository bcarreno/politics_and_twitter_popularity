# sed -f template.sed article.md

/<GRAPH1>/ {
  r graph1
  d
}

/<GRAPH2>/ {
  r graph2
  d
}
