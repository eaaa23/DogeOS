import sys

if len(sys.argv) not in (3, 4):
    print("Usage: mkEmptyFile <filename> <size> [byte]")
    sys.exit(1)

BYTE = 0
if len(sys.argv) == 4:
    strval = sys.argv[3]
    if strval.startswith("0x"):
        base = 16
    elif strval.startswith("0o"):
        base = 8
    else:
        base = 10

    try:
        val = int(strval, base=base)
    except ValueError:
        print("Invalid int: {}".format(sys.argv[3]))
        sys.exit(1)

    if val > 256 or val < 0:
        print("Byte out of range: {}".format(val))
        sys.exit(1)

    BYTE = val
    del strval, val

try:
    SIZE = int(sys.argv[2])
except ValueError:
    print("Invalid size: {}".format(sys.argv[2]))


def main() -> int:
    filename = sys.argv[1]
    try:
        with open(filename, 'wb') as fp:
            byteseq = bytes(BYTE for i in range(SIZE))
            fp.write(byteseq)
    except (FileNotFoundError, PermissionError):
        print("File open error.")
        sys.exit(1)
    return 0


if __name__ == '__main__':
    sys.exit(main())