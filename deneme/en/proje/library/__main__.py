"""Command line entry: python3 -m library --help."""

import argparse
import sys

from . import rules, store


def main(argv=None):
    parser = argparse.ArgumentParser(description="Library loan tracking")
    parser.add_argument("--data", default="library.json", help="Local JSON file")
    commands = parser.add_subparsers(dest="command", required=True)
    add = commands.add_parser("add", help="Add a book")
    add.add_argument("code")
    add.add_argument("title")
    lend = commands.add_parser("lend", help="Lend for 14 days")
    lend.add_argument("code")
    lend.add_argument("member")
    lend.add_argument("--date", required=True)
    back = commands.add_parser("return", help="Take a loan back by its number")
    back.add_argument("id", type=int)
    back.add_argument("--date", required=True)
    late = commands.add_parser("lateness", help="Compute lateness without writing to the file")
    late.add_argument("--due-date", required=True)
    late.add_argument("--return-date", required=True)
    args = parser.parse_args(argv)
    try:
        if args.command == "lateness":
            days = rules.days_late(args.due_date, args.return_date)
            print("Late: {} days".format(days))
            return 0
        data = store.read(args.data)
        if args.command == "add":
            rules.add_book(data, args.code, args.title)
            message = "Book added: " + args.code
        elif args.command == "lend":
            loan_id = rules.lend(data, args.code, args.member, args.date)
            message = "Loan no: {}".format(loan_id)
        elif args.command == "return":
            days = rules.take_back(data, args.id, args.date)
            message = "Returned. Late: {} days".format(days)
        store.write(args.data, data)
        print(message)
        return 0
    except (ValueError, OSError) as error:
        print("Error: {}".format(error), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
