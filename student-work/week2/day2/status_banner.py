# Claim pipeline banner: announce a batch of claims moving through a stage

# Create a variable named stage and give it a pipeline stage (for example "INTAKE")
stage_1 ="INTAKE"

# Loop through each letter of the stage name and print a banner line for each

counter = 0
for i in stage_1:
    print(f"Give me a {stage_1[counter]}!")
    print(f"{stage_1[counter]}!")
    counter += 1

# Print what the stage spells
print()
print("What does that spell?!")
print(f"{stage_1}! Claims are moving through {stage_1}.")
print()

# Use a second for loop over range(1, 6) to print one line per claim in the batch
print("Processing today's batch:")
for i in range(0,6):
    print(f"Claim {i+1} of 6 processed")

# for i in range(len(stage_1)+1):
#     print(f"Claim {i} of {len(stage_1)} proccessed")


claims_paid = [1200, 0, 5000, 0, 800]
for paid in claims_paid:
    if paid == 0:
        continue          # skip zero-paid claims
    print("paid:", paid)
    if paid > 4000:
        print("found a large payout, stopping")
        break
#prediction: paid:. found a large payout, stopping -incorrect
