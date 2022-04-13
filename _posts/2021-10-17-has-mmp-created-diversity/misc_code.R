
ggplot(combined, ) +
  geom_line(aes(Date, fem_frac, group = house, color=house)) +
  geom_point(aes(Date, fem_frac),
             data = combined %>% filter(house == "New Zealand")) +
  geom_vline(xintercept = ISOdate(1996,1,1), linetype="dashed") +
  theme_minimal()

nearest_nz_elec <- expand_grid(combined$Date, nz_house$Date) %>%
  mutate(days_btwn = difftime(`combined$Date`, `nz_house$Date`, units = 'days')) %>%
  filter(days_btwn >= 0) %>%   # NZ election has to happen before/same day
  group_by(`combined$Date`) %>%
  slice_min(order_by = days_btwn) %>%
  select(Date = `combined$Date`,
         NZElection = `nz_house$Date`)

control_vs_tmt <- combined %>%
  filter(house != "New Zealand") %>%
  left_join(nearest_nz_elec) %>%
  group_by(NZElection) %>%
  summarise(control = mean(fem_frac, na.rm=T)) %>%
  left_join(nz_house, by=c(NZElection = "Date")) %>%
  select(Election = NZElection,
         `Other Anglophone Legislatures` = control,
         `New Zealand` = fem_frac) %>%
  pivot_longer(cols = c(`Other Anglophone Legislatures`, `New Zealand`), names_to = "Parliament", values_to = "Female MPs %")

ggplot(control_vs_tmt %>% filter(Election >= ISOdate(1970, 1, 1))) +
  geom_line(aes(Election, `Female MPs %`, group = Parliament, color=Parliament)) +
  geom_point(aes(Election, `Female MPs %`, color=Parliament)) +
  geom_vline(xintercept = ISOdate(1994,6,15), linetype="dashed") +
  annotate("text", x = ISOdate(1987,1,1), y = 0.05, label = "Pre-MMP") + 
  annotate("text", x = ISOdate(2000,1,1), y = 0.05, label = "MMP") + 
  scale_y_continuous(labels = scales::percent, name="Women as % of Legislators") +
  ggtitle("Has MMP Increased the Number of Women in Parliament?") +
  theme_classic() +
  theme(legend.position="bottom",
        legend.title = element_blank())

data_for_graph <- combined %>%
  mutate(treatment = if_else(house == "New Zealand", "MMP", "No-MMP"),
         after = (Date >= ISOdate(1996,1,1))) %>%
  filter(Date >= ISOdate(1990,1,1), Date <= ISOdate(2001,1,1)) %>%
  group_by(treatment, after) %>%
  summarise(women = mean(fem_frac))

difference_1 <- data_for_graph[data_for_graph$treatment == "MMP" & !data_for_graph$after, "women"] - data_for_graph[data_for_graph$treatment == "No-MMP" & !data_for_graph$after, "women"]

data_for_graph[5,] <- c("Counterfactual", TRUE, data_for_graph[data_for_graph$treatment == "No-MMP" & data_for_graph$after, "women"] + difference_1)

ggplot(data_for_graph, aes(x=as.integer(after), y=women, color=treatment)) +
  geom_point(aes()) +
  geom_line(aes(group=treatment)) +
  geom_vline(xintercept = 0.5, linetype="dashed") +
  scale_y_continuous(labels = scales::percent, limits = c(0, 0.35)) +
  scale_x_continuous(breaks=c(0,1)) +
  ggtitle("Has MMP Increased the Number of Women in Parliament?") +
  annotate("segment",
           x = 0,
           y = data_for_graph[data_for_graph$treatment == "MMP" & !data_for_graph$after,]$women,
           xend = 1,
           yend = data_for_graph[data_for_graph$treatment == "Counterfactual" & data_for_graph$after,]$women,
           color = "grey",
           linetype = "dotted") +
  theme_classic() +
  theme(legend.position="bottom",
        legend.title = element_blank())