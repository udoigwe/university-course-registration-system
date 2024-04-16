<!DOCTYPE html>
<html lang="en">

<head>
    <title>Admin | Course Management | Grade Distribution</title>

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
                                        <li class="breadcrumb-item"><a href="javascript: void(0);">Dashboard</a></li>
                                        <li class="breadcrumb-item active">Course Management</li>
                                    </ol>
                                </div>
                                <h4 class="page-title">Grade Distribution</h4>
                            </div>
                        </div>
                    </div>
                    <!-- end page title -->

                    <!-- Center table row -->
                    <div class="row">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-body">
                                    <h4 class="header-title">Existing Grade Distributions</h4>
                                    <p class="text-muted font-13 mb-4">
                                        Access course grades distribution across different degree programs and departments
                                    </p>

                                    <table id="grade-distribution" class="table activate-select dt-responsive">
                                        <thead>
                                            <tr>
                                                <th>SNO</th>
                                                <th>Department Code</th>
                                                <th>Course Code</th>
                                                <th>Program Name</th>
                                                <th>Grade A Count</th>
                                                <th>Grade B Count</th>
                                                <th>Grade C Count</th>
                                                <th>Grade D Count</th>
                                                <th>Grade F Count</th>
                                                <th>Total Count</th>
                                            </tr>
                                        </thead>

                                        <tbody></tbody>
                                    </table>

                                </div> <!-- end card body-->
                            </div> <!-- end card -->
                        </div><!-- end col-->
                    </div>
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

    <!-- page script -->
    <script src="../../assets/js/pages/admin/courses.js"></script>

</body>

</html>