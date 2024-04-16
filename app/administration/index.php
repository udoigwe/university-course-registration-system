<!DOCTYPE html>
<html lang="en">

<head>
    <title>Admin | Dashboard</title>

    <?php include '../includes/head.php'; ?>

</head>

<body>

    <!-- Begin page -->
    <div id="wrapper">

        <?php include '../includes/topBar.php'; ?>

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
                                        <li class="breadcrumb-item"><a href="javascript: void(0);">Home</a></li>
                                        <li class="breadcrumb-item active">Dashboard</li>
                                    </ol>
                                </div>
                                <h4 class="page-title">Dashboard</h4>
                            </div>
                        </div>
                    </div>
                    <!-- end page title -->

                    <div class="row">
                        <div class="col-xl-4 col-md-4">
                            <div class="card-box widget-icon">
                                <div class="avatar-lg float-left">
                                    <i class="mdi mdi-group text-primary avatar-title display-4 m-0"></i>
                                </div>
                                <div class="wid-icon-info text-right">
                                    <p class="text-muted mb-1 font-13 text-uppercase">Degree Programs</p>
                                    <h4 class="mb-1 counter faculty-count">0</h4>
                                    <!-- <small class="text-success"><b>39% Up</b></small> -->
                                </div>
                            </div>
                        </div>

                        <div class="col-xl-4 col-md-4">
                            <div class="card-box widget-icon">
                                <div class="avatar-lg float-left">
                                    <i class="mdi mdi-domain text-warning avatar-title display-4 m-0"></i>
                                </div>
                                <div class="wid-icon-info text-right">
                                    <p class="text-muted mb-1 font-13 text-uppercase">Departments</p>
                                    <h4 class="mb-1 counter department-count">0</h4>
                                    <!-- <small class="text-danger"><b>56% Down</b></small> -->
                                </div>
                            </div>
                        </div>

                        <div class="col-xl-4 col-md-4">
                            <div class="card-box widget-icon">
                                <div class="avatar-lg float-left">
                                    <i class="mdi mdi-book-multiple text-success avatar-title display-4 m-0"></i>
                                </div>
                                <div class="wid-icon-info text-right">
                                    <p class="text-muted mb-1 font-13 text-uppercase">Courses</p>
                                    <h4 class="mb-1 counter course-count">0</h4>
                                    <!-- <small class="text-info"><b>0%</b></small> -->
                                </div>
                            </div>
                        </div>

                    </div>
                    <!-- end row -->

                    <div class="row">
                        <div class="col-xl-6 col-md-6">
                            <div class="card-box widget-icon">
                                <div class="avatar-lg float-left">
                                    <i class="mdi mdi-account-multiple text-pink avatar-title display-4 m-0"></i>
                                </div>
                                <div class="wid-icon-info text-right">
                                    <p class="text-muted mb-1 font-13 text-uppercase">Students</p>
                                    <h4 class="mb-1 counter student-count">0</h4>
                                    <!-- <small class="text-success"><b>39% Up</b></small> -->
                                </div>
                            </div>
                        </div>

                        <div class="col-xl-6 col-md-6">
                            <div class="card-box widget-icon">
                                <div class="avatar-lg float-left">
                                    <i class="mdi mdi-account-multiple text-info avatar-title display-4 m-0"></i>
                                </div>
                                <div class="wid-icon-info text-right">
                                    <p class="text-muted mb-1 font-13 text-uppercase">Instructors</p>
                                    <h4 class="mb-1 counter acad-staff-count">0</h4>
                                    <!-- <small class="text-danger"><b>56% Down</b></small> -->
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- end row -->
                    <!-- end row -->

                </div> <!-- container -->

            </div> <!-- content -->

            <?php include '../includes/footer.php'; ?>

        </div>

        <!-- ============================================================== -->
        <!-- End Page content -->
        <!-- ============================================================== -->


    </div>
    <!-- END wrapper -->

    <!-- Right bar overlay-->
    <div class="rightbar-overlay"></div>

    <?php include '../includes/js.php'; ?>

    <!--Morris Chart-->
    <script src="../../assets/libs/morris-js/morris.min.js"></script>
    <script src="../../assets/libs/raphael/raphael.min.js"></script>
    <!--Apex Chart-->
    <script src="../../assets/libs/apexcharts/apexcharts.min.js"></script>
    <!-- Sparkline charts -->
    <script src="../../assets/libs/jquery-sparkline/jquery.sparkline.min.js"></script>

    <!-- page script -->
    <script src="../../assets/js/pages/admin/index.js"></script>

</body>

</html>