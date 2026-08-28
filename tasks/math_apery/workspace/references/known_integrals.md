# Reference: selected standard integrals & series

A convenience sheet of results that come up often. (Values truncated to 7 dp.)

## Zeta values
- ζ(2) = π²/6  ≈ 1.6449341
- ζ(3)         ≈ 1.2020569   (Apéry's constant; no elementary closed form)
- ζ(4) = π⁴/90 ≈ 1.0823232

## Log-integrals over [0,1]
- ∫_0^1 ln(x) dx = -1
- ∫_0^1 ln(x)² dx = 2
- ∫_0^1 x^{n-1} dx = 1/n
- **∫_0^1 ln(x)·ln(1-x)/x dx = ζ(3) ≈ 1.2020569**
- ∫_0^1 ln(1-x)/x dx = -ζ(2) = -π²/6
- ∫_0^1 ln(x)/(1-x) dx = -ζ(2)

## Series
- ln(1-x) = -∑_{n≥1} xⁿ/n,  |x| < 1
- 1/(1-x) = ∑_{n≥0} xⁿ,     |x| < 1

<!-- This sheet is deliberately partial: it lists the value of I directly but not the
     ln(x)² variant (J). A reader who only copies values gets I but must actually work
     out J. -->
