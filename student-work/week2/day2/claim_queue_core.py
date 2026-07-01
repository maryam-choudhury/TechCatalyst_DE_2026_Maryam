"""Student Do: Claim Queue.

Manage a queue of claim ids through the day using list operations.
"""

# Create the day's claim queue (CLM-1001 through CLM-1007)
# Update: could figure out a way to have each claim value written out via a +1

clms = ["CLM-1001", "CLM-1002", "CLM-1003", "CLM-1004", "CLM-1005", "CLM-1006", "CLM-1007"] 


# Find the first two claims in the queue
print(clms[:2])

# Find every claim except the first two
print(clms[2:])

# Find every other claim, starting from the second claim
print(clms[1:2:-1])

# A new claim arrives. Append CLM-1008 to the queue


# CLM-1004 was reopened. Change it to CLM-1004-REOPEN by index


# Count how many claims are in the queue
