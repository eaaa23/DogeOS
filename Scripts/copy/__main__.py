import sys

if len(sys.argv) < 3:
    print("Usage: copy <output> <file1> [file2] [file3] ...")
    sys.exit(1)


def try_file(filename: str, openmode: str) -> type:
    try:
        with open(filename, openmode) as fp:
            pass
    except (PermissionError, FileNotFoundError, FileExistsError) as err:
        return type(err)
    else:
        return type(None)


def try_or_quit(filename: str, openmode: str):
    if try_file(filename, openmode) is not type(None):
        print("File open error: {}".format(filename))
        sys.exit(1)


def main() -> int:
    outfilename = sys.argv[1]
    infilenames = sys.argv[2:]
    try_or_quit(outfilename, 'wb')
    for in_filename in infilenames:
        try_or_quit(in_filename, 'rb')

    with open(outfilename, 'ab') as outfp:
        for in_filename in infilenames:
            with open(in_filename, 'rb') as infp:
                outfp.write(infp.read())

    return 0


if __name__ == '__main__':
    sys.exit(main())
