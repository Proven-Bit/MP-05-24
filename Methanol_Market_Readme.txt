This MATLAB code conducts a cost analysis for producing methanol using different feedstock configurations. It calculates the Levelized Cost of Methanol (LCOM) by considering capital expenditure (Capex) and operating expenditure (Opex) for each feedstock option over a 20-year period. The code models costs based on a specified annual methanol production target.

1. Parameter Definition
Time Period and Financial Parameters: Specifies the analysis duration (20 years), number of feedstock configurations (5 contributors), and an annual discount rate of 5%.
Exchange Rates and Pricing: Sets current exchange rates and prices for different feedstocks, water, energy (PPA price), and CO₂.
Production and Process Parameters:
Defines the annual production target for methanol.
Sets bio-methane feedstock percentage (bio_methane_feed_beta), and parameters for the electrolyzer process (efficiency and energy factor).
2. Feedstock Cost Calculations
Feedstock Cost Modeling:
Each cost calculation function models a specific feedstock option, basing calculations on the final methanol production target.
These calculations adjust for different feedstock costs, such as bio-methane, fossil methane, green hydrogen, CO₂, and water, and consider the mix or exclusivity of each feedstock type.
Specific Models:
Blended Feed Cost (calculateCostBlendedFeed): Models the cost of a blend of bio-methane and fossil methane feedstocks.
Green Hydrogen Methanol Synthesis (calculateGreenHydrogenMethanolSynthesis): Models the cost of using green hydrogen and CO₂ as feedstocks.
Water Cost for Methanol Production (calculateWaterCostMethanolProduction): Models the water cost based on total production, incorporating byproduct water and electrolyzer water requirements for varying feed percentages.
3. Capex and Opex Initialization
Initializes Capex and Opex matrices across all feedstock options.
Sets specific initial Capex values for each feedstock option in year 1.
Calculates Opex as a combination of feedstock, water, energy, and CO₂ costs based on the production target.
4. Discounted Cash Flow Analysis
Applies discounting to Capex and Opex over the analysis period using the specified interest rate.
Calculates the net present value (NPV) for Capex, Opex, and methanol production across feedstock configurations.
5. LCOM Calculation
Computes the Levelized Cost of Methanol (LCOM) for each feedstock configuration as the ratio of total NPV for Capex and Opex to the total discounted production.
6. Output and Plotting
LCOM Display: Outputs the LCOM values for troubleshooting.
Cost Plotting: Uses plotDiscountedCapexOpex to visualize discounted Capex and Opex over the 20 years, with scatter points for Capex and line plots for Opex.
7. Helper Function
plotDiscountedCapexOpex: Visualizes the discounted Capex and Opex over time for each feedstock configuration, aiding in comparative analysis.
Summary
This code provides a financial model for methanol production, comparing the economic viability of different feedstock options by calculating and plotting LCOM values. It factors in various costs associated with bio-methane, fossil methane, green hydrogen, CO₂, and water, adjusting for the impact of each configuration on the final methanol production target.