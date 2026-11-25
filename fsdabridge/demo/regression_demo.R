# Regression track demo: one line per method, on FSDA's hprice data
# (y = price, X = lot size, bedrooms, bathrooms, stories).
# Needs FSDA_DEV_VENV and FSDA_ROOT set (see .Renviron) and 'pkgload'.

pkgload::load_all(if (file.exists("DESCRIPTION")) "." else "fsdabridge")
fsda = FSDA$new(fsda_root = Sys.getenv("FSDA_ROOT"))
fsda$eval_m("load('hprice.txt')", nargout = 0)
data = fsda$eval_m("hprice")
y = data[, 1]
X = data[, 2:5]

fsda$eval_m("rng(1)", nargout = 0)

mm   = fsda$MMreg(y, X, Smsg = 0)                 # MM estimator
s    = fsda$Sreg(y, X, msg = 0)                   # S estimator
tdel = fsda$FSRaddt(y, X, plots = 1, msg = 0)     # deletion t statistics, with plot

print(cbind(MM = as.numeric(mm$beta), S = as.numeric(s$beta)))

fsda$wait_for_plot()
fsda$close()
