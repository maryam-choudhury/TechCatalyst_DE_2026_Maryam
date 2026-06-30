# Triage Faceoff: assess an incoming claim's severity against the system's reading
import random

print("=== Charter Oak Mutual: Triage Faceoff ===")

# The three severity levels, from least to most severe
levels = ["low", "medium", "high"]
rank = {"low": 1, "medium": 2, "high": 3}

# The system assigns the claim's true severity at random
actual = random.choice(levels)

# The adjuster assesses the severity
your_call = input("Assess this claim: (low), (medium), or (high)? ").strip().lower()

# TODO: Compare your_call to actual using the rank lookup.
# Handle four cases in this order:
#   1. your_call is not a valid severity
#   2. your_call matches actual (correct triage)
#   3. your_call ranks lower than actual (under-triage)
#   4. otherwise your_call ranks higher than actual (over-triage)

print(f"Actual Level: {actual}")
# print(f"Claim CLM-1001 reserve was ${reserve:.2f}")

# your_call_adjusted = rank[your_call]
# if your_call_adjusted == actual:
#     print("Correct!")

if your_call ==actual:
    print("correct triage")
elif rank[your_call] < rank[actual]:
    print("under-triage")
elif rank[your_call] > rank[actual]:
    print("over-triage")
else:
    print("ERROR: You inserted an invalid severity.")

