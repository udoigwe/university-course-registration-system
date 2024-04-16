<!DOCTYPE html>
<html lang="en">
	
	<head>
		<title>NBA Ohafia - Forgot Password</title>

		<!--========================================================================================================== -->
		<meta charset="utf-8" />
		<!-- =================== -->
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<!-- ====================================================================================================== -->
		<meta name="description" content="A fully featured admin console for NBA Ohafia" />
		<!-- ====================================================================================================== -->
		<meta name="keywords" content="NBA, OHAFIA">
		<!-- ====================================================================================================== -->
		<meta content="NBAOhafia" name="author" />
		<!-- ====================================================================================================== -->
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<!-- ====================================================================================================== -->
		<!--- General Head tags
		=========================================================================================================== -->

		<!--- Open Graph needs
		================================================== -->
		<meta property="og:site_name" content="NBA OHAFIA">
		<!--======================================================================================================= -->	
		<meta property="og:title" content="NBA Ohafia Admin Console" />
		<!--======================================================================================================= -->	
		<meta property="og:description" content="A fully featured admin console for NBA Ohafia" />
		<!--======================================================================================================= -->	
		<meta property="og:image" itemprop="image" content="/assets/images/logo1.png">
		<!--======================================================================================================= -->	
		<meta property="og:type" content="website" />
		<!--======================================================================================================= -->	
		<meta property="og:url" content="https://www.nbaohafia.org/" />
		<!--======================================================================================================= -->	
		<!--- Open Graph needs
		=========================================================================================================== -->

		<!--- Twitter needs
		=========================================================================================================== -->
		<meta name="twitter:card" content="summary_large_image" />
		<!-- ====================================================================================================== -->
		<meta property="twitter:site" content="@USERNAME">
		<!--======================================================================================================= -->
		<meta property="twitter:creator" content="@USERNAME">
		<!--======================================================================================================= -->	
		<meta property="twitter:title" content="NBA Ohafia Admin Console" />
		<!--======================================================================================================= -->	
		<meta property="twitter:description" content="A fully featured admin console for NBA Ohafia" />
		<!--======================================================================================================= -->	
		<meta property="twitter:image" content="/assets/images/logo1.png">
		<!--======================================================================================================= -->	
		<!-- Twitter needs
		=========================================================================================================== -->

		<!-- App favicon -->
		<link rel="shortcut icon" href="assets/images/logo1.png">
		
		<!-- App css -->
		<!--======================================================================================================= -->	
		<link href="assets/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
		<link href="assets/css/icons.min.css" rel="stylesheet" type="text/css" />
		<link href="assets/css/app.min.css" rel="stylesheet" type="text/css" />
		<link rel="stylesheet" type="text/css" href="assets/css/loading.css"/>
		<link rel="stylesheet" type="text/css" href="assets/css/loading-btn.css"/>
		<!-- Sweet Alert-->
		<link href="assets/libs/sweetalert2/sweetalert2.min.css" rel="stylesheet" type="text/css" />
		<!--======================================================================================================= -->

	</head>

	<body class="authentication-bg">

		<div class="account-pages mt-5 mb-5">
			<div class="container">
				<div class="row justify-content-center">
					<div class="col-md-8 col-lg-6 col-xl-5">
						<div class="card">

							<div class="card-body p-4">
							
								<div class="text-center w-75 m-auto">
									<a href="index-2.html">
										<span><img src="assets/images/logo.png" alt="nbalogo" width="100%"></span>
									</a>
									<p class="text-muted mb-4 mt-3">Enter your email address and we'll send you an email with instructions to reset your password.</p>
								</div>

								<form action="#" id="form-forgot-password">

									<div class="form-group mb-3">
										<label for="emailaddress">Email address</label>
										<input class="form-control" type="email" id="email" name="email" required="" placeholder="Enter your email">
									</div>

									<div class="form-group mb-0 text-center">
										<button class="btn btn-success btn-block ld-ext-right" type="submit" id="submit-btn">
											<span id="btn-text">Reset Password</span> 
											<div class="ld ld-ball ld-flip"></div>  
										</button>
									</div>

								</form>

							</div> <!-- end card-body -->
						</div>
						<!-- end card -->

						<div class="row mt-3">
							<div class="col-12 text-center">
								<p class="text-muted">Back to <a href="login" class="text-muted font-weight-medium ml-1">Log in</a></p>
							</div> <!-- end col -->
						</div>
						<!-- end row -->

					</div> <!-- end col -->
				</div>
				<!-- end row -->
			</div>
			<!-- end container -->
		</div>
		<!-- end page -->


		<footer class="footer footer-alt">
			&copy; <?php echo date('Y'); ?> NBA <a href="#" class="text-muted">Ohafia</a> 
		</footer>

		<!-- Vendor js -->
		<script src="assets/js/vendor.min.js"></script>

		<!-- App js -->
		<script src="assets/js/app.min.js"></script>

		<!-- CONST -->
		<script src="assets/js/const.js"></script>

		<!-- Sweet Alerts js -->
        <script src="assets/libs/sweetalert2/sweetalert2.min.js"></script>

		<!-- page functions -->
		<script src="assets/js/functions.js"></script>

		<!-- page script -->
		<script src="assets/js/pages/forgot-password.js"></script>
		
	</body>
</html>