from tools import *
from symbols import *
import commands

import sys

MSG = """
Usage: dogefs  <operation> ...
operations:
    createEmpty <size> <outputfile> <iplfilename> <siplfilename> <osfilename> [--sipl-perserve]
    """

if len(sys.argv) < 3:
    quit_with_msg(MSG)


def main(argc: int, argv: List[str]) -> int:
    COMMAND = sys.argv[1]
    if COMMAND == 'createEmpty':
        if argc < 7: quit_with_msg(MSG)
        size = 0
        try:
            size = int(argv[2])
            if size < 0:
                quit_with_msg("Below 0: {:d}".format(size))
        except ValueError:
            quit_with_msg("Not integer: {}".format(argv[2]))
        sipl_perserve = index_list_or_None(argv, 7) == '--sipl-perserve'
        commands.command_createEmpty(size, argv[3], argv[4], argv[5], argv[6], sipl_perserve)
    else:
        quit_with_msg("Not a command: {}".format(COMMAND))
    return 0


if __name__ == '__main__':
    sys.exit(main(len(sys.argv), sys.argv))
