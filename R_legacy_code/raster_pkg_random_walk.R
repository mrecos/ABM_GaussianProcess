get_raster_dir_option <- function(init_cnt_index, rast_grid, case){
  if(case == "queen"){
    directions = 8
  } else if(case == "rook"){
    directions = 4
  } else if(!(case %in% c("queen","rook"))){
    message("case needs to be on of 'queen' or 'rook'")
  }
  cell_nums <- raster::adjacent(rast_grid, init_cnt_index, directions)
}
get_hood <- function(init_cnt_index, rast_grid, search_dist=3){
  if(search_dist %% 2 == 0){
    stop("search_dist MUST BE ODD")
  }
  hood_search <- matrix(1, ncol=search_dist, nrow=search_dist, byrow=TRUE)
  hood_search[mean(seq(1:search_dist)),mean(seq(1:search_dist))] <- 0
  hood_cells <- adjacent(rast_grid,init_cnt_index,directions=hood_search, pairs=FALSE) 
  hood_cell_vals <- raster::extract(rast_grid, hood_cells)
  hood <- matrix(c(hood_cells,hood_cell_vals), ncol = 2, byrow = FALSE)
  return(hood)
}
get_min <- function(hood){
  min_cell <- hood[which(hood[,2] == min(hood[,2])),1] # return cell of min z value
  return(min_cell)
}
get_mean <- function(hood){
  hood_mean <- mean(hood[,2])
  hood <- cbind(hood, abs(hood[,2] - hood_mean))
  mean_cell <- hood[which(hood[,3] == min(hood[,3])),1] # return cell nearest mean z value
  return(mean_cell)
}
# get_current_z <- function(grid_walk){
#   wg <- na.omit(grid_walk)
#   wg <- as.numeric(wg[nrow(wg),"z"])
#   return(wg)
# }
get_walk_dir2 <- function(init_cnt_index, rast_grid, grid_walk, case = "queen"){
  dir_options <- get_raster_dir_option(init_cnt_index, rast_grid, case = case)
  hood <- get_hood(init_cnt_index, rast_grid)
  # current_z <- get_current_z(grid_walk)
  walk_dir <- get_min(hood) # <- this can be whatever function returns a cell index from hood
  return(walk_dir)
}

NLMR_to_grid <- function(NLMR_grid){
  grid_df <- raster::as.data.frame(NLMR_grid, xy = TRUE) %>%
    rename(z = layer,
           xLL = x,
           yLL = y) %>%
    mutate(xcnt = ceiling(xLL),
           ycnt = ceiling(yLL))
}

library("NLMR")
library("raster")
library("tidyverse")
library("viridis")

xmin = 0
xmax = 10
ymin = 0 
ymax = 10

nlm_grad  <- NLMR::nlm_distancegradient(xmax,ymax,origin = c(xmax, ymax, 5, 5))
NLMR::util_plot(nlm_grad)                     # <- ground truth
nlm_rand1 <- NLMR::nlm_random(xmax,ymax) * 0.5
NLMR::util_plot(nlm_rand1)
nlm_grid <- util_merge(nlm_grad, nlm_rand1) # <- observational model
# NLMR_grid[10,] <- 0
NLMR::util_plot(nlm_grid)
grid <- NLMR_to_grid(nlm_grid)
plot(values(nlm_grid),values(nlm_grad))

# initiate location
# observe value
# run model
# make decision
# move
# repeate

# modigying from sim_2d.R - added `z` value to `grid_walk[1,5]`
reps <- 30
init_cnt <- c(5,10)
walk_cnt <- cellFromXY(nlm_grid, init_cnt)
grid_walk <- data.frame(matrix(ncol=5,nrow=(reps+1)))
colnames(grid_walk) <- c("rep","x","y","z","adv")
# initiate results/walk matrix/grid
grid_walk[1,1] <- as.integer(1)
grid_walk[1,2] <- as.numeric(xFromCell(nlm_grid, walk_cnt))
grid_walk[1,3] <- as.numeric(yFromCell(nlm_grid, walk_cnt))
grid_walk[1,4] <- as.numeric(nlm_grid[walk_cnt])
grid_walk[1,5] <- NA
for(i in seq_len(reps)){
  current_z <- nlm_grad[walk_cnt]
  walk_cnt_i <- get_walk_dir2(walk_cnt,nlm_grid,grid_walk,"queen")
  new_z <- nlm_grad[walk_cnt_i]
  grid_walk[(i+1),1] <- as.integer(i+1)
  grid_walk[(i+1),2] <- as.numeric(xFromCell(nlm_grid, walk_cnt_i))
  grid_walk[(i+1),3] <- as.numeric(yFromCell(nlm_grid, walk_cnt_i))
  grid_walk[(i+1),4] <- as.numeric(nlm_grid[walk_cnt_i])
  grid_walk[(i+1),5] <- ifelse(new_z < current_z, 1, 0)
  walk_cnt <- walk_cnt_i
}

# ggplot(grid_walk, aes(x=rep,y=z)) +
#   geom_line() +
#   theme_bw()

ggplot() +
  geom_raster(data = grid, aes(x=xcnt, y=ycnt, fill = z)) +
  geom_path(data = grid_walk, aes(ceiling(x),ceiling(y)), color = "gray10", size = 0.75) +
  # geom_point(data = grid_walk, aes(x,y)) +
  coord_equal() +
  scale_x_continuous(breaks = seq(1,(xmax+0.5),1), 
                     labels = seq(1,(xmax+0.5),1),
                     # limits = c(xmin,xmax),
                     expand=c(0,0)) +
                     # limits = c(c((xmin+0.5),(xmax+0.5)))) +
  scale_y_continuous(breaks = seq(1,(ymax+0.5),1), 
                     labels = seq(1,(ymax+0.5),1),
                     # limits = c(ymin,ymax),
                     expand=c(0,0)) +
                     # limits = c((ymin+0.5),(ymax+0.5))) +
  scale_fill_viridis(option="viridis")

