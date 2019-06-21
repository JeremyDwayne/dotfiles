CC=			gcc
CFLAGS=		-Wall -std=gnu99
LDFLAGS=	
LIBS=		-lm
SOURCE=		$(wildcard *.c)
PROGRAMS=	$(SOURCE:.c=)

all:	$(PROGRAMS)

%:%.c
		$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

clean:
		rm -f $(PROGRAMS)

test:
		
