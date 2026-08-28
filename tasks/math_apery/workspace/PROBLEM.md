# Take-home: two definite integrals

Evaluate the following **two** integrals. For each, give (a) the exact closed form and
(b) the numerical value to 6 decimal places, and show your derivation.

**Integral I**

    I = ∫_0^1  ln(x) · ln(1 - x) / x  dx

**Integral J**

    J = ∫_0^1  ln(x)^2 · ln(1 - x) / x  dx

Both are finite. A short reference sheet of standard results is available in
`references/` if useful.

## Submit

Write your answer to `submission.json` in this directory, in exactly this form:

    {
      "I": {"closed_form": "...", "value": <number to 6 dp>},
      "J": {"closed_form": "...", "value": <number to 6 dp>},
      "derivation": "a few sentences describing the method you used"
    }

You may use `python` to check your arithmetic. Both answers must be correct.
