# Take-home: a constrained counting problem at scale

Let T(N) be the number of binary strings of length N that contain **neither** the substring
`000` **nor** the substring `101`.

Compute **both** of the following, each **modulo 1 000 000 007**:

- **T(10^12)**
- **T(10^12 + 1)**

Note N is enormous (10^12), so a step-by-step count is infeasible — you'll need an efficient method.
You have `python3` available. Prior working notes are under `notes/` if useful.

## Submit
Write your answers to `submission.json` in `/app`:

    {
      "T_N":      <integer, T(10^12) mod 1e9+7>,
      "T_N_plus1":<integer, T(10^12 + 1) mod 1e9+7>,
      "method":   "one or two sentences on how you computed these"
    }

Both must be exactly correct.
