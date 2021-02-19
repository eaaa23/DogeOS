from symbol import *


def checkfile(filename: str, opentype: str) -> bool:
    try:
        fp = open(filename, opentype)
        fp.close()
    except Exception as e:
        return False
    else:
        return True


def quit_with_msg(msg: str):
    print(msg, file=sys.stderr)
    sys.exit(1)


def checkfile_or_quit(filename: str, opentype: str):
    if not checkfile(filename, opentype):
        quit_with_msg("File open error: {}".format(filename))


def file_fill_to(fp, dest: int):
    size = dest - fp.tell()
    if size > 0:
        fp.write(bytes(size))


def index_list_or_None(lst: list, idx: int):
    try:
        return lst[idx]
    except IndexError:
        return None
