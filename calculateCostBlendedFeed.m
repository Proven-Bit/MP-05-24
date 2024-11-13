function Cost_blended_feed = calculateCostBlendedFeed(annual_production, fossil_methane_feed_price, bio_methane_feed_price, bio_methane_feed_beta)
    % Calculate the cost of the blended feed based on the annual production rate
    % and prices of fossil and bio methane feeds.
    %
    % Inputs:
    % - annual_production: Annual production rate
    % - fossil_methane_feed_price: Price of fossil methane feed
    % - bio_methane_feed_price: Price of bio methane feed
    % - bio_methane_feed_beta: Percentage of bio methane feed (as a percentage, e.g., 50 for 50%)
    %
    % Output:
    % - Cost_blended_feed: Calculated cost of the blended feed

    % Formula for calculating the cost of blended feed
    Cost_blended_feed = (0.3838 * annual_production * fossil_methane_feed_price) - ...
        (0.3838 * annual_production * (bio_methane_feed_beta / 100) * ...
        (fossil_methane_feed_price - bio_methane_feed_price));
end

