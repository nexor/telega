module telega.test;

import des.ts : assertEq;

void assertEquals(A, E)(A actual, E expected, string file=__FILE__, size_t line=__LINE__)
{
    assertEq(expected, actual, "Assertion failed.\nExpected value: %s, actual value: %s", file, line);
}
