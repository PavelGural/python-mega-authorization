import os
import json
from mega import Mega

# Example format for EMAIL_PASSWORD_PAIRS environment variable
# EMAIL_PASSWORD_PAIRS='[{"email": "email1", "password": "password1"}, {"email": "email2", "password": "password2"}]'


def parse_account_pairs(pairs_str):
    """Parse a JSON string of email-password pairs into a list of dictionaries."""
    return json.loads(pairs_str)


def mega_login_multiple(accounts):
    """
    Log in to multiple Mega accounts using a list of email-password pairs.

    Parameters:
    accounts (list of dictionaries): A list where each dictionary contains an email and a password.      

    Returns:
    list: A list of Mega instances for the successfully logged in accounts.
    """
    mega_instances = []
    for account in accounts:
        email = account["email"]
        password = account["password"]
        try:
            mega = Mega()
            m = mega.login(email, password)
            print(f"Login successful for {email}")
            mega_instances.append(m)
        except Exception as e:
            print(f"Failed to log in for {email}: {e}")
    return mega_instances


if __name__ == "__main__":
    # Fetch the email-password pairs from an environment variable
    account_pairs_str = os.getenv('EMAIL_PASSWORD_PAIRS')
    if not account_pairs_str:
        raise ValueError(
            "EMAIL_PASSWORD_PAIRS environment variable is not set.")

    accounts = parse_account_pairs(account_pairs_str)
    mega_instances = mega_login_multiple(accounts)
