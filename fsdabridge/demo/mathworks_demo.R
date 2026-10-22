# Live demo for the MathWorks meeting: LXS -> FSReda -> resfwdplot, run
# through the FSDA R6 class, on FSDA's own "Houses Price Dataset"
# (regression/hprice.txt, as used in FSRBbsb.m's/FSRBeda.m's own help
# examples: y = price, X = lot size, bedrooms, bathrooms, stories).
#
# Works sourced from fsdabridge/ or from the RSandbox project root.
# Needs FSDA_DEV_VENV and FSDA_ROOT set (see .Renviron) and 'pkgload'.

pkgload::load_all(if (file.exists("DESCRIPTION")) "." else "fsdabridge")

fsda_root = path.expand(Sys.getenv("FSDA_ROOT"))
fsda = FSDA$new(fsda_root = fsda_root)

data = as.matrix(read.table(file.path(fsda_root, "datasets", "regression", "hprice.txt")))
y = data[, 1]
X = data[, 2:5]
colnames(X) = c("lot_size", "bedrooms", "bathrooms", "stories")
print(head(cbind(price = y, X)))

out  = fsda$LXS(y, X, nsamp = 1000, plots = 0, msg = 0)
out1 = fsda$FSReda(y, X, out$bs)
fsda$resfwdplot(out1)

fsda$wait_for_plot()
fsda$close()