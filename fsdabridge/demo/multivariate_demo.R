# Multivariate methods contributed on the ahmed/multivariate branch.
# Requires MATLAB, FSDA, FSDA_DEV_VENV and FSDA_ROOT; see .Renviron.

pkgload::load_all(if (file.exists("DESCRIPTION")) "." else "fsdabridge")
fsda = FSDA$new(fsda_root = Sys.getenv("FSDA_ROOT"))

fsda$eval_m("load('hprice.txt')", nargout = 0)
data = fsda$eval_m("hprice")
Y = data[, 2:4]

# Robust location/scatter estimators
mcd_out = fsda$mcd(Y, nsamp = 100, plots = 0, msg = 0)
smult_out = fsda$Smult(Y, nsamp = 100, plots = 0, msg = 0)
mmmult_out = fsda$MMmult(Y, Snsamp = 100, plots = 0, Smsg = 0)
mve_out = fsda$mve(Y, nsamp = 100, plots = 0, msg = 0)

# Forward search and its exploratory/monitoring forms
fsm_out = fsda$FSM(Y, plots = 0, msg = 0)
fsmeda_out = fsda$FSMeda(Y, bsb = 0, plots = 0, msg = 0)
fsm_mmd = fsda$FSMmmd(Y, bsb = 0, plots = 0, msg = 0)

# Principal component analysis; biplot=0 prevents opening the interactive app.
pca_out = fsda$pcaFS(Y, biplot = 0, plots = 0, dispresults = FALSE)

print(list(mcd = mcd_out, FSM = fsm_out, FSMeda = fsmeda_out,
           Smult = smult_out, MMmult = mmmult_out, mve = mve_out,
           pcaFS = pca_out, FSMmmd = fsm_mmd))
fsda$close()
