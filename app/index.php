<!DOCTYPE html>
<html lang="en">
<head>
    <title>My Account</title>
    
    <?php include 'includes/head.php'; ?>

</head>

<body onload="notLoggedInCheck(); displayUserProfile();">

    <!-- Begin page -->
    <div id="wrapper">

        <?php include 'includes/topBar.php'; ?>

        <?php include 'leftSideBar.php'; ?>

        <!-- ============================================================== -->
        <!-- Start Page Content here -->
        <!-- ============================================================== -->

        <div class="content-page">
                <div class="content">

                    <!-- Start Content-->
                    <div class="container-fluid">
                        
                        <!-- start page title -->
                        <div class="row">
                            <div class="col-12">
                                <div class="page-title-box">
                                    <div class="page-title-right">
                                        <ol class="breadcrumb m-0">
                                            <li class="breadcrumb-item"><a href="javascript: void(0);">Dashboard</a></li>
                                            <li class="breadcrumb-item active">My Account</li>
                                        </ol>
                                    </div>
                                    <h4 class="page-title">Profile</h4>
                                </div>
                            </div>
                        </div>     
                        <!-- end page title --> 

                        <div class="row">
                            <div class="col-lg-4 col-xl-4">
                                <div class="card-box text-center">
                                    <img class="rounded-circle avatar-xl img-thumbnail my-avatar">

                                    <h4 class="mb-0 my-full-name"></h4>
                                    <p class="text-muted my-office"></p>

                                    <div class="text-left mt-3">
                                        <p class="text-muted mb-2 font-13"><strong>Full Name :</strong> <span class="ml-2 my-full-name"></span></p>

                                        <p class="text-muted mb-2 font-13"><strong>Phone :</strong><span class="ml-2 my-phone"></span></p>

                                        <p class="text-muted mb-2 font-13"><strong>Email :</strong> <span class="ml-2 my-email"></span></p>

                                        <p class="text-muted mb-2 font-13"><strong>Role :</strong> <span class="ml-2 my-role"></span></p>

                                        <p class="text-muted mb-1 font-13"><strong>Organization :</strong> <span class="ml-2 my-organization"></span></p>
                                    </div>
                                </div> <!-- end card-box -->

                            </div> <!-- end col-->

                            <div class="col-lg-8 col-xl-8">
                                <div class="card-box">
                                    <ul class="nav nav-pills navtab-bg">
                                        <li class="nav-item">
                                            <a href="#account-settings" data-toggle="tab" aria-expanded="false" class="nav-link active">
                                                <i class="mdi mdi-account-card-details mr-1"></i>Account Settings
                                            </a>
                                        </li>
                                        <li class="nav-item">
                                            <a href="#security-settings" data-toggle="tab" aria-expanded="false" class="nav-link">
                                                <i class="mdi mdi-lock mr-1"></i>Security Settings
                                            </a>
                                        </li>
                                    </ul>

                                    <div class="tab-content">

                                        <div class="tab-pane show active" id="account-settings">
                                            <form id="form-update-profile" enctype="multipart/form-data">
                                                <h5 class="mb-3 text-uppercase bg-light p-2"><i class="mdi mdi-account-circle mr-1"></i> Personal Info</h5>
                                                
                                                <div class="row">
                                                    <div class="col-12">
                                                        <div class="form-group">
                                                            <label for="user_firstname">First Name <span class="red-asteriks">*</span></label>
                                                            <input type="text" class="form-control required" id="user_firstname" name="user_firstname" placeholder="Enter your first name">
                                                        </div>
                                                    </div>
                                                </div> <!-- end row -->

                                                <div class="row">
                                                    <div class="col-12">
                                                        <div class="form-group">
                                                            <label for="user_lastname">Last Name <span class="red-asteriks">*</span></label>
                                                            <input type="text" class="form-control required" id="user_lastname" name="user_lastname" placeholder="Enter your last name">
                                                        </div>
                                                    </div>
                                                </div> <!-- end row -->

                                                <div class="row">
                                                    <div class="col-md-6">
                                                        <div class="form-group">
                                                            <label for="user_email">Email Address <span class="red-asteriks">*</span></label>
                                                            <input type="email" class="form-control required" id="user_email" name="user_email" placeholder="Enter email">
                                                            <span class="form-text text-muted"><small>Your preffered email must be unique (Not used by another user)</small></span>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <div class="form-group">
                                                            <label for="user_phone">Phone <span class="red-asteriks">*</span></label>
                                                            <input type="text" class="form-control required" id="user_phone" name="user_phone" placeholder="Enter phone">
                                                            <span class="form-text text-muted"><small>Your preffered phone number must be unique (Not used by another user)</small></span>
                                                        </div>
                                                    </div> <!-- end col -->
                                                </div> <!-- end row -->

                                                <h5 class="mb-3 text-uppercase bg-light p-2"><i class="mdi mdi-camera-wireless mr-1"></i>Profile Photo</h5>
                                                <div class="row">
                                                    <div class="col-12">
                                                        <div class="form-group">
                                                            <label for="avatar">Profile Photo</label>
                                                            <input type="file" class="form-control" id="avatar" name="avatar" placeholder="Change your profile photo (Optional)">
                                                        </div>
                                                    </div>
                                                    <div class="col-md-12" id="imgprev" style="display: none; text-align: center">
                                                        <img width="200" height="200" id="imgpreview" class="img-circle">
                                                    </div>
                                                </div> <!-- end row -->
                                                
                                                <div class="text-right">
                                                    <button type="submit" class="btn btn-success waves-effect waves-light mt-2"><i class="mdi mdi-content-save"></i> Save</button>
                                                </div>
                                            </form>
                                        </div>
                                        <!-- end settings content-->

                                        <div class="tab-pane" id="security-settings">
                                            <form id="form-update-password">
                                                <h5 class="mb-3 text-uppercase bg-light p-2"><i class="mdi mdi-lock mr-1"></i> Security Settings</h5>
                                                
                                                <div class="form-group">
                                                    <label for="current_password" class="col-form-label">Current Password</label>
                                                    <input type="password" class="form-control required" id="current_password" name="current_password" placeholder="Current password">
                                                </div>
                                                <div class="form-group">
                                                    <label for="new_password" class="col-form-label">New Password</label>
                                                    <input type="password" class="form-control required" id="new_password" name="new_password" placeholder="New prefered password">
                                                </div>
                                                <div class="form-group">
                                                    <label for="re_password" class="col-form-label">Confirm Password</label>
                                                    <input type="password" class="form-control required" id="re_password" name="re_password" placeholder="Must match new password">
                                                </div>
                                                
                                                <div class="text-right">
                                                    <button type="submit" class="btn btn-success waves-effect waves-light mt-2"><i class="mdi mdi-content-save"></i> Save</button>
                                                </div>
                                            </form>
                                        </div>
                                        <!-- end settings content-->

                                    </div> <!-- end tab-content -->
                                </div> <!-- end card-box-->

                            </div> <!-- end col -->
                        </div>
                        <!-- end row-->
                        
                    </div> <!-- container -->

                </div> <!-- content -->

                <?php include 'includes/footer.php'; ?>

            </div>

        <!-- ============================================================== -->
        <!-- End Page content -->
        <!-- ============================================================== -->

    </div>
    <!-- END wrapper -->

    <?php include 'includes/rightSideBar.php'; ?>

    <!-- Right bar overlay-->
    <div class="rightbar-overlay"></div>

    <?php include 'includes/js.php'; ?>

    <!-- page script -->
    <script src="../assets/js/pages/admin/account.js"></script>
    
</body>
</html>