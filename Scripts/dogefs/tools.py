from symbols import *


def int2bytes(source_int: int, output_size_at_least:int=0) -> bytes:
    lst = []
    current = source_int
    while current:
        lst.append(current & 0xff)
        current >>= 8
    while len(lst) < output_size_at_least:
        lst.append(0)
    return bytes(lst)


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
    sys.exit(3)


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
