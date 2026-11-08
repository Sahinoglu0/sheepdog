"""Business rules. Dates are ISO formatted: YYYY-MM-DD."""

from datetime import date, timedelta


def days_late(due_date, return_date):
    return (date.fromisoformat(return_date) - date.fromisoformat(due_date)).days


def add_book(data, code, title):
    if not code.strip() or not title.strip():
        raise ValueError("Book code and title must not be empty")
    if code in data["books"]:
        raise ValueError("Book code already exists")
    data["books"][code] = title


def lend(data, code, member, day):
    start = date.fromisoformat(day)
    if code not in data["books"]:
        raise ValueError("Book not found")
    if not member.strip():
        raise ValueError("Member name must not be empty")
    if any(l["book"] == code and l["returned"] is None for l in data["loans"]):
        raise ValueError("Book is already on loan")
    record = {
        "id": len(data["loans"]) + 1,
        "book": code,
        "member": member,
        "date": day,
        "due_date": (start + timedelta(days=14)).isoformat(),
        "returned": None,
    }
    data["loans"].append(record)
    return record["id"]


def take_back(data, loan_id, day):
    returned = date.fromisoformat(day)
    for record in data["loans"]:
        if record["id"] != loan_id:
            continue
        if record["returned"] is not None:
            raise ValueError("Loan was already returned")
        if returned < date.fromisoformat(record["date"]):
            raise ValueError("Return cannot be before the loan date")
        late = days_late(record["due_date"], day)
        record["returned"] = day
        return late
    raise ValueError("Loan not found")
