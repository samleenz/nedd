test_that("Files are saved to correct place", {
  dir.create("tmp", showWarnings = F)
  hnet_prepare(ascher_graph, "tmp")
  expect_equal(
    TRUE,
    file.exists("tmp/edge_list_ascher.tsv") & file.exists("tmp/index_gene_ascher.tsv")
    )
  unlink("tmp", recursive = T)
})
