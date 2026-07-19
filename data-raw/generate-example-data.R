hydromeso_example <- data.frame(
  x = 500000 + seq(0, 170, by = 10),
  y = 4400000 + seq(0, 170, by = 10),
  depth = c(0.2, 0.8, 1.5, 0.2, 0.2, 0.8, 0.8, 1.5,
            0.609999, 0.61, 1.369999, 1.37, 0.2, 0.2, 0.8, 0.8, NA, 0),
  velocity = c(0.1, 0.1, 0.1, 0.4, 0.8, 0.4, 0.8, 0.8,
               0.299999, 0.299999, 0.299999, 0.299999,
               0.609999, 0.61, 0.609999, 0.61, 0.2, 0)
)
save(hydromeso_example, file = "data/hydromeso_example.rda", version = 2)

