/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "NULL";

/* maximum output string length */
#define MAXLEN 2048

static const struct arg args[] = {
	/* function        format          argument */
  { run_command, "[VOL %s]",   "simple-volume"},
	{ datetime,       "[%s]",           "%d %b %Y | %R" },
};
