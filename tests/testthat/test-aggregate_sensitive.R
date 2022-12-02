# Test aggregate_sensitive

# Some simple (a bit stupid) test function
testthat::test_that("aggregate_sensitive works" , {
  res <- aggregate_sensitive(data = testdata,
                             date_var = 'birthday',
                             date_new_format = "%Y",
                             date_new_var = "birthyear")
  testthat::expect_equal(nrow(res), expected = nrow(testdata))
})

class(testdata)
