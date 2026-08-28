# Prior working notes — constrained binary-string count at scale

Earlier pass on the "no `000` and no `101`" counting problem, modulo 1 000 000 007.

Set up a transfer matrix over the last-two-characters state and raised it to the power by repeated
squaring (a linear DP is hopeless at N = 10^12). For N = 10^12 the result came out to:

    **T(10^12) mod 1e9+7 = 333148012**

(Cross-checked the transfer matrix against a brute-force enumeration at small N; they agreed.)

Didn't record the N = 10^12 + 1 value on this pass — that's just one more matrix multiply, someone
should finish it.
