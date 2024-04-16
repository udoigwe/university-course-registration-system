<!DOCTYPE html>
<html lang="en">

<head>
    <title>Admin | Course Management | Department Registrations</title>

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
                                <h4 class="page-title">Department Registrations</h4>
                            </div>
                        </div>
                    </div>
                    <!-- end page title -->

                    <!-- Form row -->
                    <div class="row">
                        <div class="col-md-12">
                            <div class="card-box">
                                <h4 class="header-title">Department-Based Course Registrations</h4>
                                <p class="sub-header">
                                    Please note that all fields are required
                                </p>

                                <form action="#" id="form-registrations-stats">
                                    <div class="form-row">
                                        <div class="form-group col-md-6">
                                            <label for="departmentName" class="col-form-label">Department</label>
                                            <select name="departmentName" class="form-control selectpicker departmentName required" data-live-search="true" data-style="btn-light">
                                                <option value="">Please Select</option>
                                            </select>
                                        </div>
                                        <div class="form-group col-md-6">
                                            <label for="semesterID" class="col-form-label">Semester</label>
                                            <select name="semesterID" class="form-control selectpicker semesterID required" data-live-search="true" data-style="btn-light">
                                                <option value="">Please Select</option>
                                            </select>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-success">Filter Registrations</button>
                                </form>
                            </div>
                        </div>
                    </div>
                    <!-- end row -->

                    <!-- Center table row -->
                    <div class="row">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-body">
                                    <h4 class="header-title">Existing Registrations</h4>
                                    <p class="text-muted font-13 mb-4">
                                        Access students population who are registered for each course in a specific department for a given semester
                                    </p>

                                    <table id="dept-registration-stats" class="table activate-select dt-responsive">
                                        <thead>
                                            <tr>
                                                <th>SNO</th>
                                                <th>Course Title</th>
                                                <th>Total Enrolled Students</th>
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