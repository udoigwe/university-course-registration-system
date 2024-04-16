<!DOCTYPE html>
<html lang="en">

<head>
    <title>Admin | User Management</title>

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
                                        <li class="breadcrumb-item"><a href="javascript: void(0);">User Management</a></li>
                                        <li class="breadcrumb-item active">Students</li>
                                    </ol>
                                </div>
                                <h4 class="page-title">Students Management</h4>
                            </div>
                        </div>
                    </div>
                    <!-- end page title -->

                    <!-- Form row -->
                    <div class="row">
                        <div class="col-md-12">
                            <div class="card-box">
                                <h4 class="header-title">New Student</h4>
                                <p class="sub-header">
                                    Please note that all fields marked with red asteriks(*) are required
                                </p>

                                <form action="#" id="form-new-student">
                                    <div class="form-row">
                                        <div class="form-group col-md-6">
                                            <label for="firstName" class="col-form-label">First Name <span class="red-asteriks">*</span></label>
                                            <input type="text" class="form-control required firstName" name="firstName" placeholder="First Name">
                                        </div>
                                        <div class="form-group col-md-6">
                                            <label for="lastName" class="col-form-label">Last Name <span class="red-asteriks">*</span></label>
                                            <input type="text" class="form-control required lastName" name="lastName" placeholder="Last Name">
                                        </div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group col-md-4">
                                            <label for="email" class="col-form-label">Email <span class="red-asteriks">*</span></label>
                                            <input type="email" class="form-control required email" name="email" placeholder="Valid email address">
                                        </div>
                                        <div class="form-group col-md-4">
                                            <label for="phoneNumber" class="col-form-label">Phone <span class="red-asteriks">*</span></label>
                                            <input type="text" class="form-control required phoneNumber" name="phoneNumber" placeholder="Country codes apply">
                                        </div>
                                        <div class="form-group col-md-4">
                                            <label for="gender" class="col-form-label">Gender <span class="red-asteriks">*</span></label>
                                            <select name="gender" class="form-control selectpicker gender required">
                                                <option value="">Choose a gender</option>
                                                <option value="Male">Male</option>
                                                <option value="Female">Female</option>
                                                <option value="Other">Other</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group col-md-6">
                                            <label for="programID" class="col-form-label">Program <span class="red-asteriks">*</span></label>
                                            <select name="programID" class="form-control selectpicker programID required" data-live-search="true" data-style="btn-light">
                                                <option value="">Choose a program</option>
                                            </select>
                                        </div>
                                        <div class="form-group col-md-6">
                                            <label for="classification" class="col-form-label">Classification <span class="red-asteriks">*</span></label>
                                            <select name="classification" class="form-control selectpicker classification required">
                                                <option value="">Choose a classification</option>
                                                <option value="Junior">Junior</option>
                                                <option value="Sophomore">Sophomore</option>
                                                <option value="Freshman">Freshman</option>
                                                <option value="Graduate">Graduate</option>
                                                <option value="Senior">Senior</option>
                                            </select>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-success ld-ext-right">Submit</button>
                                </form>
                            </div>
                        </div>
                    </div>
                    <!-- end row -->

                    <!-- Users table row -->
                    <div class="row">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-body">
                                    <h4 class="header-title">Existing Students</h4>
                                    <p class="text-muted font-13 mb-4">
                                        Click the edit or delete buttons attached to a student to update OR delete a student record respectively
                                    </p>

                                    <table id="students" class="table activate-select dt-responsive">
                                        <thead>
                                            <tr>
                                                <th>SNO</th>
                                                <th>First Name</th>
                                                <th>Last Name</th>
                                                <th>Email</th>
                                                <th>Phone Number</th>
                                                <th>Gender</th>
                                                <th>Program</th>
                                                <th>Classification</th>
                                                <th>Actions</th>
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
                        <div class="modal-dialog modal-dialog-centered modal-lg">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h4 class="modal-title"></h4>
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                                </div>
                                <div class="modal-body p-4">
                                    <form action="#" id="form-update-student" enctype="multipart/form-data">
                                        <div class="form-row">
                                            <div class="form-group col-md-6">
                                                <label for="firstName" class="col-form-label">First Name <span class="red-asteriks">*</span></label>
                                                <input type="text" class="form-control required firstName" name="firstName" placeholder="First Name">
                                            </div>
                                            <div class="form-group col-md-6">
                                                <label for="lastName" class="col-form-label">Last Name <span class="red-asteriks">*</span></label>
                                                <input type="text" class="form-control required lastName" name="lastName" placeholder="Last Name">
                                            </div>
                                        </div>
                                        <div class="form-row">
                                            <div class="form-group col-md-4">
                                                <label for="email" class="col-form-label">Email <span class="red-asteriks">*</span></label>
                                                <input type="email" class="form-control required email" name="email" placeholder="Valid email address">
                                            </div>
                                            <div class="form-group col-md-4">
                                                <label for="phoneNumber" class="col-form-label">Phone <span class="red-asteriks">*</span></label>
                                                <input type="text" class="form-control required phoneNumber" name="phoneNumber" placeholder="Country codes apply">
                                            </div>
                                            <div class="form-group col-md-4">
                                                <label for="gender" class="col-form-label">Gender <span class="red-asteriks">*</span></label>
                                                <select name="gender" class="form-control selectpicker gender required">
                                                    <option value="">Choose a gender</option>
                                                    <option value="Male">Male</option>
                                                    <option value="Female">Female</option>
                                                    <option value="Other">Other</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-row">
                                            <div class="form-group col-md-6">
                                                <label for="programID" class="col-form-label">Program <span class="red-asteriks">*</span></label>
                                                <select name="programID" class="form-control selectpicker programID required" data-live-search="true" data-style="btn-light">
                                                    <option value="">Choose a program</option>
                                                </select>
                                            </div>
                                            <div class="form-group col-md-6">
                                                <label for="classification" class="col-form-label">Classification <span class="red-asteriks">*</span></label>
                                                <select name="classification" class="form-control selectpicker classification required">
                                                    <option value="">Choose a classification</option>
                                                    <option value="Junior">Junior</option>
                                                    <option value="Sophomore">Sophomore</option>
                                                    <option value="Freshman">Freshman</option>
                                                    <option value="Graduate">Graduate</option>
                                                    <option value="Senior">Senior</option>
                                                </select>
                                            </div>
                                        </div>
                                        <input type="hidden" name="studentID" class="required studentID">
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary waves-effect" data-dismiss="modal">Close</button>
                                    <button type="submit" class="btn btn-success waves-effect waves-light">Save changes</button>
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
    <script src="../../assets/js/pages/admin/students.js"></script>

</body>

</html>