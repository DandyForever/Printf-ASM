#include <stdio.h>

extern void _myprintf (const char* , ...);

int main ()
{
	_myprintf ("string %s, char %c, dec %d, hex %x, bin %b, oct %o, %c%c%c%c, and %c %s %x %d%%", "Hello", 78, 1234, 3802, 31, 111, 'l', 'o', 'l', '!', 'I', "Love", 3802, 100);
	return 0;	
}
