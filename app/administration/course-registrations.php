<!DOCTYPE html>
<html lang="en">

<head>
    <title>Admin | Course Management | Course Registrations</title>

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
                                <h4 class="page-title">Course Registrations</h4>
                            </div>
                        </div>
                    </div>
                    <!-- end page title -->

                    <!-- Form row -->
                    <div class="row">
                        <div class="col-md-12">
                            <div class="card-box">
                                <h4 class="header-title">New Course Registration</h4>
                                <p class="sub-header">
                                    Please note that all fields are required
                                </p>

                                <form action="#" id="new-course-registration">
                                    <div class="form-row">
                                        <div class="form-group col-md-4">
                                            <label for="courseCode" class="col-form-label">Course Code</label>
                                            <select name="courseCode" class="form-control selectpicker courseCode required" data-live-search="true" data-style="btn-light">
                                                <option value="">Please Select</option>
                                            </select>
                                        </div>
                                        <div class="form-group col-md-4">
                                            <label for="semesterID" class="col-form-label">Semester</label>
                                            <select name="semesterID" class="form-control selectpicker semesterID required" data-live-search="true" data-style="btn-light">
                                                <option value="">Please Select</option>
                                            </select>
                                        </div>
                                        <div class="form-group col-md-4">
                                            <label for="studentID" class="col-form-label">Student</label>
                                            <select name="studentID" class="form-control selectpicker studentID required" data-live-search="true" data-style="btn-light">
                                                <option value="">Please Select</option>
                                            </select>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-success">Submit</button>
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
                                        Access all student course registrations across all semesters
                                    </p>

                                    <table id="course-registrations" class="table activate-select dt-responsive">
                                        <thead>
                                            <tr>
                                                <th>SNO</th>
                                                <th>First Name</th>
                                                <th>Last Name</th>
                                                <th>Classification</th>
                                                <th>Program</th>
                                                <th>Course Code</th>
                                                <th>Semester</th>
                                                <th>Academic Year</th>
                                                <th>Registration Date</th>
                                                <th>Withdrawal Date</th>
                                                <th>Registration Status</th>
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