#!/bin/sh
#
#Script for make and run program
#
#

# FIT THE (GOOD DEFAULT) PARAMETER TO THE ALGORTIHMS
#	- Huber-ROF-Model: alpha = 0.05, lambda = 32.0, tau = 0.01, sigma = 0.0, theta = 1.0, cartoon = -1
#	- Image Inpainting: alpha = 0.05, lambda = 32.0, tau = 0.01, sigma = 0.0, theta = 1.0, cartoon = -1
#	- TVL1-Model: alpha = 0.05, lambda = 0.7, tau = 0.35, sigma = 1.0 / (0.35 * 8.0), theta = 1.0, cartoon = -1
#	- Real-Time-Minimizer: alpha = 20.0, lambda = 0.1, tau = 0.25, sigma = 0.5, theta = 1.0, cartoon = 1/0
#

make

# TVLROF Model
# ./iPaur "../../img/lena_noise.png" "../../noise_0_0.7.png" 0 0.7 500
# ./iPaur "../../img/lena_noise.png" "../../noise_0_0.png" 0 0 500
# ./iPaur "../../img/lena_noise.png" "../../noise_0.01_0.1.png" 0.01 0.1 500
# ./iPaur "../../img/lena_noise.png" "../../noise_0.1_40.png" 0.1 40 500
# ./iPaur "../../img/lena_noise.png" "../../noise_0.01_40.png" 0.01 40 500
# ./iPaur "../../img/lena_noise.png" "../../noise_0.001_40.png" 0.001 40 500
# ./iPaur "../../img/lena_noise.png" "../../noise_0.01_64.png" 0.01 64 500
# ./iPaur "../../img/lena_noise.png" "../../noise_0.01_100.png" 0.01 100 500
# ./iPaur "../../img/lena_noise.png" "../../noise_0.3_0.1.png" 0.3 0.1 500
# ./iPaur "../../img/lena_noise.png" "../../noise_0.7_0.png" 0.7 0 500

./iPaur "../../img/miche.jpg" "../../miche_test.png" 400 0.1 500

# ./iPaur "../../img/lena_noise.png" "../../noise_4_0.7.png" 4 0.7 50
# ./iPaur "../../img/lena_noisy.png" "../../noisy_4_0.7.png" 4 0.7 50
# ./iPaur "../../img/lena.png" "../../lena_4_0.7.png" 4 0.7 50

# RT Model
# ./iPaur "../../img/lena_noise.png" "../../noise_1_0.1.png" 1 0.1 500
# ./iPaur "../../img/lena_noise.png" "../../noise_0.01_1.png" 0.01 1 500
# ./iPaur "../../img/lena_noisy.png" "../../noisy_1_0.1.png" 1 0.1 500
# ./iPaur "../../img/lena_noisy.png" "../../noisy_10_7.png" 10 7 500
# ./iPaur "../../img/lena.png" "../../lena_10_7.png" 10 7 500
# ./iPaur "../../img/lena.png" "../../lena_0.01_1.png" 0.01 1 500

# ./iPaur "../../img/lena_noise.png" "../../noise_10_7.png" 10 7 2500
# ./iPaur "../../img/lena_noisy.png" "../../noisy_0.01_1.png" 0.01 1 2500
# ./iPaur "../../img/lena.png" "../../lena_1_0.1.png" 1 0.1 2500

# TVL1 Model
# ./iPaur "../../img/lena_noise.png" "../../noise_0.9.png" 0.9 0 500
# ./iPaur "../../img/lena_noise.png" "../../noise_1.2.png" 1.2 0 500
# ./iPaur "../../img/lena_noisy.png" "../../noisy_0.9.png" 0.9 0 500
# ./iPaur "../../img/lena_noisy.png" "../../noisy_1.2.png" 1.2 0 500
# ./iPaur "../../img/lena.png" "../../lena_0.9.png" 0.9 0 500
# ./iPaur "../../img/lena.png" "../../lena_1.2.png" 1.2 0 500

# ./iPaur "../../img/lena_noise.png" "../../noise_0.7.png" 0.7 0 2500
# ./iPaur "../../img/lena_noisy.png" "../../noisy_0.7.png" 0.7 0 2500
# ./iPaur "../../img/lena.png" "../../lena_0.7.png" 0.7 0 2500

# ROF Model
# ./iPaur "../../img/lena_noise.png" "../../noise_16.png" 16 0 500
# ./iPaur "../../img/lena_noise.png" "../../noise_32.png" 32 0 500
# ./iPaur "../../img/lena_noisy.png" "../../noisy_16.png" 16 0 500
# ./iPaur "../../img/lena_noisy.png" "../../noisy_32.png" 32 0 500
# ./iPaur "../../img/lena.png" "../../lena_16.png" 16 0 500
# ./iPaur "../../img/lena.png" "../../lena_32.png" 32 0 500

# ./iPaur "../../img/lena_noisy.png" "../../noisy_8.png" 8 0 2500
# ./iPaur "../../img/lena_noise.png" "../../noise_8.png" 8 0 2500
# ./iPaur "../../img/lena.png" "../../lena_8.png" 8 0 2500


# ./iPaur "tests/min.jpg" "tests/min_new.jpg"
# ./iPaur "tests/Wafer_Detection/max.jpg" "tests/max_new5.jpg"
# ./iPaur "tests/max.jpg" "tests/max_new.jpg"
# ./iPaur "tests/test.png" "tests/test1.png"
# ./iPaur "./img/Wafer/Small/1.jpg" "./img/Wafer/Small/detect/1_RobertsCross.jpg"

# _________________________________________________________________________________________________________
# TI pictures
# _________________________________________________________________________________________________________
# for j in "gauss" "mean" "canny" "laplace" "erosion" "Ierosion" "dilatation" "Idilatation" "close" "Iclose" "inverse"
# do
	# for (( i = 1; i < 16; i++ ));
	# do
	# 	echo "$i"
	# 	./iPaur "./img/Wafer/Small/$i.jpg" "./img/Wafer/Small/detect/$i-RobertsCross.jpg" # "$j" "3"
	# done
# done
# _________________________________________________________________________________________________________


# _________________________________________________________________________________________________________
# Linear Filter
# _________________________________________________________________________________________________________
# for i in "gauss" "duto" "mean"
# do
# 	./ImageProcessing "../img/lena_noisy.png" "../img/lena_noisy_$i.png" "$i" "3"
# done
# _________________________________________________________________________________________________________


# _________________________________________________________________________________________________________
# Edge Detection
# _________________________________________________________________________________________________________
# for i in "log" "canny" "log" "sobel" "prewitt" "roberts"
# do
	# ./ImageProcessing "../img/ball.png" "../img/ball_$i.png" "$i" "3"
	# ./ImageProcessing "../img/fcb.png" "../img/fcb_$i.png" "$i" "15"
	# ./ImageProcessing "../img/apple.png" "../img/apple_$i.png" "$i" "3"
	# ./ImageProcessing "../img/image.png" "../img/image_$i.png" "$i" "3"
	# ./ImageProcessing "../img/lena_noisy.png" "../img/lena_$i.png" "$i" "9"
# done
# _________________________________________________________________________________________________________

# for i in "transform_rgb" "transform_hsi" "transform_ycrcb";
# do
# 	./ImageProcessing "../img/$i.png" "../img/$i_new.png"
# done
# ./ImageProcessing "../img/miche.jpg" "../img/miche_new.jpg" "../img/miche_original.jpg"
# ./ImageProcessing "../img/lena_color_new.png" "../img/lena_color_edge.png" "../img/lena_color_original.png"
# ./ImageProcessing "../img/miche.jpg" "../img/miche_new.jpg"
# ./ImageProcessing "../img/wafer_original.png" "../img/wafer_original_new.png"
# ./ImageProcessing "../img/wafer.png" "../img/wafer_new.png"

# ./ImageProcessing "../img/la_dama.jpg" "../img/belladonna.jpg"
# ./ImageProcessing "../img/trash.png" "../img/trash_new.png"
# ./ImageProcessing "../img/pyramide_new.png" "../img/pyramide_new2.png"
# ./ImageProcessing "../img/pyramide_new1.png" "../img/pyramide_new2.png"
# ./ImageProcessing "../img/pyramide.png" "../img/pyramide_new0.png"
# ./ImageProcessing "../img/lena.png" "../img/lena_new.png" "gauss" "3"
# ./ImageProcessing "../img/belladonna.jpg" "../img/belladonna_new.jpg"

# ./ImageProcessing "../img/M.png" "../img/M_piv.png"
# ./ImageProcessing "../img/lena_color.png" "../img/lena_face.png"
# ./ImageProcessing "../img/jobs.jpg" "../img/jobs_face.png"
# ./ImageProcessing "../img/kd.jpg" "../img/kd_face.png"
# ./ImageProcessing "../img/miche.jpg" "../img/miche_face.png"

# _________________________________________________________________________________________________________
# Morphological Filter
# _________________________________________________________________________________________________________
# for i in "inverse" "erosion" "dilatation" "open" "close" "whitetophat" "blacktophat" #"hitormiss"
# do
# 	./ImageProcessing "../img/lena.png" "../img/lena_$i.png" "$i" "3"
# 	./ImageProcessing "../img/one_standard.png" "../img/one_standard_$i.png" "$i" "3"
# done
# _________________________________________________________________________________________________________


# _________________________________________________________________________________________________________
# Testing with inversion, erosion, reinversion
# _________________________________________________________________________________________________________
# ./ImageProcessing "../img/image.png" "../img/image_inverse.png" "inverse" "3"
# ./ImageProcessing "../img/image_inverse.png" "../img/image_inverse_erosion.png" "erosion" "3"
# ./ImageProcessing "../img/image_inverse_erosion.png" "../img/image_reinverse_erosion.png" "inverse" "3"
# ./ImageProcessing "../img/lena.png" "../img/lena_inverse.png" "inverse" "3"
# ./ImageProcessing "../img/lena_inverse.png" "../img/lena_inverse_erosion.png" "erosion" "3"
# ./ImageProcessing "../img/lena_inverse_erosion.png" "../img/lena_reinverse_erosion.png" "inverse" "3"
# _________________________________________________________________________________________________________


# _________________________________________________________________________________________________________
# Valgrind
# _________________________________________________________________________________________________________
# ./main "../img/lena.png" "../img/lena_systemTest.png" "canny"
# valgrind ./ImageProcessing "../img/test.png" "../img/test_test.png" "gauss" "3" > testDrive.txt 2>&1
# valgrind --leak-check=full ./ImageProcessing "../img/lena_noisy.png" "../img/lena_systemTest.png" "laplace" "3" > testDrive.txt 2>&1
# valgrind --track-origins=yes ./ImageProcessing "../img/test.png" "../img/test_systemTest.png" "canny" "3" > testDrive.txt 2>&1
# _________________________________________________________________________________________________________

# find . -type f -name '*.o' -delete