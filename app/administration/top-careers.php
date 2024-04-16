<!DOCTYPE html>
<html lang="en">

<head>
    <title>Admin | Course Management | Top Careers</title>

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
                                <h4 class="page-title">Top Career Ratings</h4>
                            </div>
                        </div>
                    </div>
                    <!-- end page title -->

                    <!-- Center table row -->
                    <div class="row">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-body">
                                    <h4 class="header-title">Existing Career Ratings</h4>
                                    <p class="text-muted font-13 mb-4">
                                        Access top 3 career tags that have the most course recommendations, with corresponding course codes for each career tag
                                    </p>

                                    <table id="top-careers" class="table activate-select dt-responsive">
                                        <thead>
                                            <tr>
                                                <th>SNO</th>
                                                <th>Career Title</th>
                                                <th>Number Of Recommendations</th>
                                                <th>Recommended Courses</th>
                                            </tr>
                                        </thead>

                                        <tbody></tbody>
                                    </table>

                                </div> <!-- end card body-->
                            </div> <!-- end card -->
                        </div><!-- end col-->
                    </div>
                    <!-- end row -->

                    <!-- edit modal -->
                    <div id="editModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" style="display: none;">
                        <div class="modal-dialog modal-dialog-centered modal-full">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h4 class="modal-title"></h4>
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                                </div>
                                <div class="modal-body p-4">
                                    <form action="#" id="form-update-course">
                                        <div class="form-row">
                                            <div class="form-group col-md-6">
                                                <label for="department_id" class="col-form-label">Department <span class="red-asteriks">*</span></label>
                                                <select name="department_id" class="form-control required selectpicker department_id" data-live-search="true" data-style="btn-light">
                                                    <option value="">Choose a Department</option>
                                                </select>
                                            </div>
                                            <div class="form-group col-md-6">
                                                <label for="level_code" class="col-form-label">Level <span class="red-asteriks">*</span></label>
                                                <select name="level_id" class="form-control required selectpicker level_id" data-live-search="true" data-style="btn-light">
                                                    <option value="">Choose a Level</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="course_title" class="col-form-label">Course Title <span class="red-asteriks">*</span></label>
                                            <input type="text" class="form-control required course_title" name="course_title" placeholder="Course Title">
                                        </div>
                                        <div class="form-row">
                                            <div class="form-group col-md-6">
                                                <label for="course_type" class="col-form-label">Course Type <span class="red-asteriks">*</span></label>
                                                <select name="course_type" class="form-control required selectpicker course_type" data-live-search="true" data-style="btn-light">
                                                    <option value="">Choose a Course Type</option>
                                                    <option value="General Course">General Course</option>
                                                    <option value="Departmental Course">Departmental Course</option>
                                                </select>
                                            </div>
                                            <div class="form-group col-md-6">
                                                <label for="course_semester" class="col-form-label">Course Semester <span class="red-asteriks">*</span></label>
                                                <select name="course_semester" class="form-control required selectpicker course_semester" data-live-search="true" data-style="btn-light">
                                                    <option value="">Choose a Course Semester</option>
                                                    <option value="First Semester">First Semester</option>
                                                    <option value="Second Semester">Second Semester</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-row">
                                            <div class="form-group col-md-4">
                                                <label for="course_code" class="col-form-label">Course Code <span class="red-asteriks">*</span></label>
                                                <input type="text" class="form-control required course_code" name="course_code" placeholder="Course Code (Unique)">
                                            </div>
                                            <div class="form-group col-md-4">
                                                <label for="course_unit" class="col-form-label">Course Unit <span class="red-asteriks">*</span></label>
                                                <input type="text" class="form-control required integersonly course_unit" name="course_unit" placeholder="Course Unit (Digits Only)">
                                            </div>
                                            <div class="form-group col-md-4">
                                                <label for="course_status" class="col-form-label">Course Status <span class="red-asteriks">*</span></label>
                                                <select name="course_status" class="form-control required selectpicker course_status">
                                                    <option value="">Choose a status</option>
                                                    <option value="Active">Active</option>
                                                    <option value="Inactive">Inactive</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-form-label" for="course_description">Course Description <span class="red-asteriks">*</span></label>
                                            <textarea id="course_description1" class="form-group col-md-12 required"></textarea>
                                        </div>
                                        <input type="hidden" name="course_id" class="required course_id">
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary waves-effect" data-dismiss="modal">Close</button>
                                    <button type="submit" class="btn btn-info waves-effect waves-light" id="submit-btn1">
                                        <span id="btn-text1">Save changes</span>
                                    </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div><!-- /.modal -->


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