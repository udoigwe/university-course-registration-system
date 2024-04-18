$(function () {

    'use strict';

    let token = sessionStorage.getItem('token');

    $(document).ready(function($) {

        loadCourses();
        loadSemesters();
        loadStudents();
        loadCourseRegistrations2();
        loadDepartments();
        loadCrossDepartmentalInstructors();
        loadPrograms();
        loadCoursePrerequisites();
        loadDepartmentalTotalEnrollments();
        loadMultiDisciplinaryStudents();
        loadTopCareers();
        loadCareerTags();
        loadGradeDistribution();

        $('#form-students-filter').on("submit", function(e){
            e.preventDefault();

            var form = $(this);
            var semesterID = form.find('select.semesterID').val();
            var courseTitle = form.find('select.courseTitle').val();
            var fields = form.find('input.required, select.required');

            for(var i=0;i<fields.length;i++)
            {
                if(fields[i].value == "")
                {
                    /*alert(fields[i].id);*/
                    unblockUI();  
                    showSimpleMessage("Attention", `${fields[i].name} is required`, "error");
                    form.find(`[name="${fields[i].name}"]`).focus();
                    return false;
                }
            }

            loadCourseRegistrations(semesterID, courseTitle);
        });

        //filter department specific registrations
        $('#form-registrations-stats').on("submit", function(e){
            e.preventDefault();

            var form = $(this);
            var departmentName = form.find('select.departmentName').val();
            var semesterID = form.find('select.semesterID').val();
            var fields = form.find('input.required, select.required');

            for(var i=0;i<fields.length;i++)
            {
                if(fields[i].value == "")
                {
                    /*alert(fields[i].id);*/
                    unblockUI();  
                    showSimpleMessage("Attention", `${fields[i].name} is required`, "error");
                    form.find(`[name="${fields[i].name}"]`).focus();
                    return false;
                }
            }

            loadCourseDepartmentRegistrations(departmentName, semesterID);
        });
        
        //filter Program-specific Average Course Statistics
        $('#form-program-average-course-stats').on("submit", function(e){
            e.preventDefault();

            var form = $(this);
            var programName = form.find('select.programName').val();
            var fields = form.find('input.required, select.required');

            for(var i=0;i<fields.length;i++)
            {
                if(fields[i].value == "")
                {
                    /*alert(fields[i].id);*/
                    unblockUI();  
                    showSimpleMessage("Attention", `${fields[i].name} is required`, "error");
                    form.find(`[name="${fields[i].name}"]`).focus();
                    return false;
                }
            }

            loadProgramSpecificAVGCourseStat(programName);
        });

        //submit new course registration
        $('#new-course-registration').on("submit", function(e){
            e.preventDefault();
            newCourseRegistration();
        });
        
        //submit new withdrawal form
        $('#withdraw-course-registration').on("submit", function(e){
            e.preventDefault();
            withdrawCourseRegistration();
        });

        //submit new career tag
        $('#new-career-tag').on("submit", function(e){
            e.preventDefault();
            newCareerTag();
        });

        $('#gpas').on('click', '.btn-print', function(){
            var userID = $(this).attr('user-id');
            var semesterID = $(this).attr('semester-id');
            var printModal = $('#printModal');

            blockUI();

            //fetch user details
            $.ajax({
                url: `${API_URL_ROOT}/result-sheet?semester_id=${semesterID}&user_id=${userID}`,
                type: 'GET',
                dataType: 'json',
                headers:{'x-access-token':token},
                success: function(response)
                {
                    if(response.error == false)
                    {
                        var summary = response.gpa;
                        var scores = response.scores;
                        var serial = 0;
                        var itemsHTML = '';

                        printModal.find('.modal-title').text(`${summary.fullname}'s Result Sheet`);
                        printModal.find('.fullname').text(summary.fullname);
                        printModal.find('.reg_no').text(summary.reg_no);
                        printModal.find('.department').text(summary.department);
                        printModal.find('.level_code').text(summary.level_code);
                        printModal.find('.semester').text(summary.semester);
                        printModal.find('.session').text(summary.session);
                        printModal.find('.gpa').text(summary.GPA.toFixed(2));
                        printModal.find('.next-semester-opening').text(`${summary.next_resumption_timestamp ? moment.unix(summary.next_resumption_timestamp).format('MMMM Do, YYYY') : ''}`);

                        for(var i = 0; i < scores.length; i++)
                        {
                            var score = scores[i];

                            itemsHTML += `
                                <tr>
                                    <td>${serial += 1}</td>
                                    <td>${score.course_title}</td>
                                    <td>${score.course_code}</td>
                                    <td>${score.course_type}</td>
                                    <td>${score.course_unit}</td>
                                    <td>${score.ca_score}</td>
                                    <td>${score.exam_score}</td>
                                    <td>${score.total_score}</td>
                                    <td>${score.grade}</td>
                                    <td>${score.grade_remarks}</td>
                                </tr>
                            `
                        }                            

                        printModal.find('#item-list tbody').html(itemsHTML);

                        unblockUI();
                    }
                    else
                    {
                        showSimpleMessage("Attention", response.message, "error");   
                        unblockUI();
                    }
                },
                error: function(req, status, error)
                {
                    showSimpleMessage("Attention", "ERROR - "+req.status+" : "+req.statusText, "error");
                }
            });
        });
    });

    //load departments
    function loadDepartments()
    {
        blockUI();

        $.ajax({
            type:'GET',
            url: `${API_URL_ROOT}/index?call=departments&action=get_departments`,
            dataType: 'json',
            success: function(response)
            {
                if(response.error == false)
                {
                    var departments = response.departments;
                    var html = '';

                    for(var i = 0; i < departments.length; i++)
                    {
                        html += `
                            <option value="${departments[i].departmentName}">${departments[i].departmentName}</option>
                        `
                    }

                    $("select.departmentName").append(html);
                    $('.selectpicker').selectpicker('refresh');
                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");       
                }
            },
            error:function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.responseText, "error");
            }

        })
    }

    //load courses
    function loadCourses()
    {
        blockUI();

        $.ajax({
            type:'GET',
            url: `${API_URL_ROOT}/index?call=courses&action=get_all_courses`,
            dataType: 'json',
            headers:{ 'x-access-token':token},
            success: function(response)
            {
                if(response.error == false)
                {
                    var courses = response.courses;
                    var html = '';
                    var html2 = '';

                    for(var i = 0; i < courses.length; i++)
                    {
                        html += `
                            <option value="${courses[i].courseTitle}">${courses[i].courseTitle} (${courses[i].courseCode})</option>
                        `
                        html2 += `
                            <option value="${courses[i].courseCode}">${courses[i].courseCode} (${courses[i].courseTitle})</option>
                        `
                    }

                    $("select.courseTitle").append(html);
                    $("select.courseCode").append(html2);
                    $('.selectpicker').selectpicker('refresh');
                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");       
                }
            },
            error:function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.statusText, "error");
            }

        })
    }

    //load semesters
    function loadSemesters()
    {
        blockUI();

        $.ajax({
            type:'GET',
            url: `${API_URL_ROOT}/index?call=semesters&action=get_semesters`,
            dataType: 'json',
            headers:{ 'x-access-token':token},
            success: function(response)
            {
                if(response.error == false)
                {
                    var semesters = response.semesters;
                    var html = '';

                    for(var i = 0; i < semesters.length; i++)
                    {
                        html += `
                            <option value="${semesters[i].semesterID}">${semesters[i].semesterName} (${semesters[i].academicYear})</option>
                        `
                    }

                    $("select.semesterID").append(html);
                    $('.selectpicker').selectpicker('refresh');
                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");       
                }
            },
            error:function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.statusText, "error");
            }

        })
    }

    //load get course specific semester registrations
    function loadCourseRegistrations(semesterID, courseTitle)
    {
        var table = $('#registered-students');

        blockUI();

        $.ajax({
            type: "GET",
            url: `${API_URL_ROOT}/index?call=courses&action=get_course_specific_semester_registrations&semesterID=${semesterID}&courseTitle=${courseTitle}`,
            dataType: "json",
            contentType: "application/json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const registrations = response.registrations;
                    
                    table.DataTable({
                        oLanguage: {
                            oPaginate: { 
                                sPrevious: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-left"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>', "sNext": '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-right"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>' 
                            },
                            sInfo: "Showing _START_ to _END_ of _TOTAL_ entries",
                            sSearch: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>',
                            sSearchPlaceholder: "Search...",
                           sLengthMenu: "Results :  _MENU_",
                        },
                        lengthMenu: [7, 10, 20, 50, 100],
                        stripeClasses: [],
                        drawCallback: function () { $('.dataTables_paginate > .pagination').addClass(' pagination-style-13 pagination-bordered mb-5'); },
                        language: {
                            infoEmpty: "<span style='color:red'><b>No records found</b></span>"
                        },
                        processing: true,
                        serverSide: false,
                        destroy: true,
                        autoWidth: false,
                        pageLength: 100,
                        data: registrations,
                        columns: [
                            {
                                data: '',
                                render: function (data, type, row, meta) 
                                {
                                    return meta.row + meta.settings._iDisplayStart + 1;
                                }
                            },
                            {data: 'FirstName'},
                            {data: 'LastName'},
                            {data: 'Email'}
                        ]  
                    });

                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");
                }
            },
            error: function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.responseText, "error");
            }
        })

    }

    //internal function to add new course registration
    function newCourseRegistration() 
    {
        swal({
            title: "Attention",
            text: "Are you sure you want to register this course?",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: "#DD6B55",
            confirmButtonText: "Yes!",
            cancelButtonText: "No!"
            /*closeOnConfirm: false,
            closeOnCancel: false*/
        }).then(function(result){

            if (result.value) 
            {
                //name vairables
                var form = $('#new-course-registration'); //form
                var fields = form.find('input.required, select.required');
                
                blockUI();

                for(var i=0;i<fields.length;i++)
                {
                    if(fields[i].value == "")
                    {
                        /*alert(fields[i].id);*/
                        unblockUI();  
                        showSimpleMessage("Attention", `${fields[i].name} is required`, "error");
                        form.find(`name=["${fields[i].name}"]`).focus();
                        return false;
                    }
                }

                $.ajax({
                    type: 'POST',
                    url: `${API_URL_ROOT}/index?call=courses&action=create_new_course_registration`,
                    data: form.serialize(),
                    dataType: 'json',
                    success: function(response)
                    {
                        if(response.error == false)
                        {
                            unblockUI(); 
                            showSimpleMessage("Success", response.message, "success");
                            form.get(0).reset();
                            $('.selectpicker').selectpicker('refresh');
                            loadCourseRegistrations2();
                        }
                        else
                        {
                            unblockUI();   
                            showSimpleMessage("Attention", response.message, "error");
                        }
                    },
                    error: function(req, status, error)
                    {
                        unblockUI();   
                        showSimpleMessage("Attention", req.responseText, "error");
                    }
                }); 
            } 
            else 
            {
                showSimpleMessage('Canceled', 'Process Abborted', 'error');
            }
        });
    }

    //internal function to add new career tag
    function newCareerTag() 
    {
        swal({
            title: "Attention",
            text: "Are you sure you want to register this new career tag?",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: "#DD6B55",
            confirmButtonText: "Yes!",
            cancelButtonText: "No!"
            /*closeOnConfirm: false,
            closeOnCancel: false*/
        }).then(function(result){

            if (result.value) 
            {
                //name vairables
                var form = $('#new-career-tag'); //form
                var fields = form.find('input.required, select.required');
                
                blockUI();

                for(var i=0;i<fields.length;i++)
                {
                    if(fields[i].value == "")
                    {
                        /*alert(fields[i].id);*/
                        unblockUI();  
                        showSimpleMessage("Attention", `${fields[i].name} is required`, "error");
                        form.find(`name=["${fields[i].name}"]`).focus();
                        return false;
                    }
                }

                $.ajax({
                    type: 'POST',
                    url: `${API_URL_ROOT}/index?call=career&action=add_career_tag`,
                    data: form.serialize(),
                    dataType: 'json',
                    success: function(response)
                    {
                        if(response.error == false)
                        {
                            unblockUI(); 
                            showSimpleMessage("Success", response.message, "success");
                            form.get(0).reset();
                            $('.selectpicker').selectpicker('refresh');
                            loadCareerTags();
                        }
                        else
                        {
                            unblockUI();   
                            showSimpleMessage("Attention", response.message, "error");
                        }
                    },
                    error: function(req, status, error)
                    {
                        unblockUI();   
                        showSimpleMessage("Attention", req.responseText, "error");
                    }
                }); 
            } 
            else 
            {
                showSimpleMessage('Canceled', 'Process Abborted', 'error');
            }
        });
    }

    //internal function to withdraw course registration
    function withdrawCourseRegistration() 
    {
        swal({
            title: "Attention",
            text: "Are you sure you want to withdraw this course registration?",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: "#DD6B55",
            confirmButtonText: "Yes!",
            cancelButtonText: "No!"
            /*closeOnConfirm: false,
            closeOnCancel: false*/
        }).then(function(result){

            if (result.value) 
            {
                //name vairables
                var form = $('#withdraw-course-registration'); //form
                var fields = form.find('input.required, select.required');
                
                blockUI();

                for(var i=0;i<fields.length;i++)
                {
                    if(fields[i].value == "")
                    {
                        /*alert(fields[i].id);*/
                        unblockUI();  
                        showSimpleMessage("Attention", `${fields[i].name} is required`, "error");
                        form.find(`name=["${fields[i].name}"]`).focus();
                        return false;
                    }
                }

                $.ajax({
                    type: 'POST',
                    url: `${API_URL_ROOT}/index?call=courses&action=cancel_course_registration`,
                    data: form.serialize(),
                    dataType: 'json',
                    success: function(response)
                    {
                        if(response.error == false)
                        {
                            unblockUI(); 
                            showSimpleMessage("Success", response.message, "success");
                            form.get(0).reset();
                            $('.selectpicker').selectpicker('refresh');
                            loadCourseRegistrations2();
                        }
                        else
                        {
                            unblockUI();   
                            showSimpleMessage("Attention", response.message, "error");
                        }
                    },
                    error: function(req, status, error)
                    {
                        unblockUI();   
                        showSimpleMessage("Attention", req.responseText, "error");
                    }
                }); 
            } 
            else 
            {
                showSimpleMessage('Canceled', 'Process Abborted', 'error');
            }
        });
    }

    //load students
    function loadStudents()
    {
        blockUI();

        $.ajax({
            type:'GET',
            url: `${API_URL_ROOT}/index?call=users&action=get_students`,
            dataType: 'json',
            headers:{ 'x-access-token':token},
            success: function(response)
            {
                if(response.error == false)
                {
                    var students = response.students;
                    var html = '';

                    for(var i = 0; i < students.length; i++)
                    {
                        html += `
                            <option value="${students[i].studentID}">${students[i].firstName} ${students[i].lastName}</option>
                        `
                    }

                    $("select.studentID").append(html);
                    $('.selectpicker').selectpicker('refresh');
                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");       
                }
            },
            error:function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.statusText, "error");
            }

        })
    }

    //load all course registrations
    function loadCourseRegistrations2()
    {
        var table = $('#course-registrations');

        blockUI();

        $.ajax({
            type: "GET",
            url: `${API_URL_ROOT}/index?call=courses&action=get_all_course_registrations`,
            dataType: "json",
            contentType: "application/json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const registrations = response.registrations;
                    
                    table.DataTable({
                        oLanguage: {
                            oPaginate: { 
                                sPrevious: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-left"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>', "sNext": '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-right"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>' 
                            },
                            sInfo: "Showing _START_ to _END_ of _TOTAL_ entries",
                            sSearch: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>',
                            sSearchPlaceholder: "Search...",
                           sLengthMenu: "Results :  _MENU_",
                        },
                        lengthMenu: [7, 10, 20, 50, 100],
                        stripeClasses: [],
                        drawCallback: function () { $('.dataTables_paginate > .pagination').addClass(' pagination-style-13 pagination-bordered mb-5'); },
                        language: {
                            infoEmpty: "<span style='color:red'><b>No records found</b></span>"
                        },
                        processing: true,
                        serverSide: false,
                        destroy: true,
                        autoWidth: false,
                        pageLength: 100,
                        data: registrations,
                        columns: [
                            {
                                data: '',
                                render: function (data, type, row, meta) 
                                {
                                    return meta.row + meta.settings._iDisplayStart + 1;
                                }
                            },
                            {data: 'firstName'},
                            {data: 'lastName'},
                            {data: 'classification'},
                            {data: 'programName'},
                            {data: 'courseCode'},
                            {data: 'semesterName'},
                            {data: 'academicYear'},
                            {data: 'registrationDate'},
                            {data: 'withdrawalDate'},
                            {data: 'registrationStatus'},
                        ]  
                    });

                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");
                }
            },
            error: function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.responseText, "error");
            }
        })
    }

    //load department specific registrations
    function loadCourseDepartmentRegistrations(departmentName, semesterID)
    {
        var table = $('#dept-registration-stats');

        blockUI();

        $.ajax({
            type: "GET",
            url: `${API_URL_ROOT}/index?call=courses&action=get_department_specific_semester_registrations&departmentName=${departmentName}&semesterID=${semesterID}`,
            dataType: "json",
            contentType: "application/json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const registrations = response.registrations;
                    
                    table.DataTable({
                        oLanguage: {
                            oPaginate: { 
                                sPrevious: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-left"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>', "sNext": '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-right"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>' 
                            },
                            sInfo: "Showing _START_ to _END_ of _TOTAL_ entries",
                            sSearch: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>',
                            sSearchPlaceholder: "Search...",
                           sLengthMenu: "Results :  _MENU_",
                        },
                        lengthMenu: [7, 10, 20, 50, 100],
                        stripeClasses: [],
                        drawCallback: function () { $('.dataTables_paginate > .pagination').addClass(' pagination-style-13 pagination-bordered mb-5'); },
                        language: {
                            infoEmpty: "<span style='color:red'><b>No records found</b></span>"
                        },
                        processing: true,
                        serverSide: false,
                        destroy: true,
                        autoWidth: false,
                        pageLength: 100,
                        data: registrations,
                        columns: [
                            {
                                data: '',
                                render: function (data, type, row, meta) 
                                {
                                    return meta.row + meta.settings._iDisplayStart + 1;
                                }
                            },
                            {data: 'CourseTitle'},
                            {data: 'EnrolledStudents'}
                        ]  
                    });

                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");
                }
            },
            error: function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.responseText, "error");
            }
        })
    }

    //load cross departmental instructors
    function loadCrossDepartmentalInstructors()
    {
        var table = $('#cross-dept-instructors');

        blockUI();

        $.ajax({
            type: "GET",
            url: `${API_URL_ROOT}/index?call=courses&action=get_cross_departmental_instructors`,
            dataType: "json",
            contentType: "application/json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const instructors = response.instructors;
                    
                    table.DataTable({
                        oLanguage: {
                            oPaginate: { 
                                sPrevious: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-left"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>', "sNext": '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-right"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>' 
                            },
                            sInfo: "Showing _START_ to _END_ of _TOTAL_ entries",
                            sSearch: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>',
                            sSearchPlaceholder: "Search...",
                           sLengthMenu: "Results :  _MENU_",
                        },
                        lengthMenu: [7, 10, 20, 50, 100],
                        stripeClasses: [],
                        drawCallback: function () { $('.dataTables_paginate > .pagination').addClass(' pagination-style-13 pagination-bordered mb-5'); },
                        language: {
                            infoEmpty: "<span style='color:red'><b>No records found</b></span>"
                        },
                        processing: true,
                        serverSide: false,
                        destroy: true,
                        autoWidth: false,
                        pageLength: 100,
                        data: instructors,
                        columns: [
                            {
                                data: '',
                                render: function (data, type, row, meta) 
                                {
                                    return meta.row + meta.settings._iDisplayStart + 1;
                                }
                            },
                            {data: 'FirstName'},
                            {data: 'LastName'},
                            {data: 'NumDepartments'}
                        ]  
                    });

                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");
                }
            },
            error: function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.responseText, "error");
            }
        })
    }

    //load Program-specific Average Course Statistics
    function loadProgramSpecificAVGCourseStat(programName)
    {
        var table = $('#average-courses-stats');

        blockUI();

        $.ajax({
            type: "GET",
            url: `${API_URL_ROOT}/index?call=courses&action=get_program_average_course_stats&programName=${programName}`,
            dataType: "json",
            contentType: "application/json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const stats = response.stats;
                    
                    table.DataTable({
                        oLanguage: {
                            oPaginate: { 
                                sPrevious: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-left"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>', "sNext": '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-right"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>' 
                            },
                            sInfo: "Showing _START_ to _END_ of _TOTAL_ entries",
                            sSearch: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>',
                            sSearchPlaceholder: "Search...",
                           sLengthMenu: "Results :  _MENU_",
                        },
                        lengthMenu: [7, 10, 20, 50, 100],
                        stripeClasses: [],
                        drawCallback: function () { $('.dataTables_paginate > .pagination').addClass(' pagination-style-13 pagination-bordered mb-5'); },
                        language: {
                            infoEmpty: "<span style='color:red'><b>No records found</b></span>"
                        },
                        processing: true,
                        serverSide: false,
                        destroy: true,
                        autoWidth: false,
                        pageLength: 100,
                        data: stats,
                        columns: [
                            {
                                data: '',
                                render: function (data, type, row, meta) 
                                {
                                    return meta.row + meta.settings._iDisplayStart + 1;
                                }
                            },
                            {data: 'programName'},
                            {data: 'AvgCoursesTaken'}
                        ]  
                    });

                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");
                }
            },
            error: function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.responseText, "error");
            }
        })
    }

    //load course prerequisites
    function loadCoursePrerequisites()
    {
        var table = $('#course-prerequisites');

        blockUI();

        $.ajax({
            type: "GET",
            url: `${API_URL_ROOT}/index?call=courses&action=get_course_prerequisites`,
            dataType: "json",
            contentType: "application/json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const prerequisites = response.prerequisites;
                    
                    table.DataTable({
                        oLanguage: {
                            oPaginate: { 
                                sPrevious: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-left"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>', "sNext": '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-right"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>' 
                            },
                            sInfo: "Showing _START_ to _END_ of _TOTAL_ entries",
                            sSearch: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>',
                            sSearchPlaceholder: "Search...",
                           sLengthMenu: "Results :  _MENU_",
                        },
                        lengthMenu: [7, 10, 20, 50, 100],
                        stripeClasses: [],
                        drawCallback: function () { $('.dataTables_paginate > .pagination').addClass(' pagination-style-13 pagination-bordered mb-5'); },
                        language: {
                            infoEmpty: "<span style='color:red'><b>No records found</b></span>"
                        },
                        processing: true,
                        serverSide: false,
                        destroy: true,
                        autoWidth: false,
                        pageLength: 100,
                        data: prerequisites,
                        columns: [
                            {
                                data: '',
                                render: function (data, type, row, meta) 
                                {
                                    return meta.row + meta.settings._iDisplayStart + 1;
                                }
                            },
                            {data: 'CourseCode'},
                            {data: 'CourseTitle'},
                            {data: 'PrerequisiteCourseCode'},
                            {data: 'PrerequisiteCourseTitle'},
                        ]  
                    });

                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");
                }
            },
            error: function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.responseText, "error");
            }
        })
    }

    //load departmental total enrollments
    function loadDepartmentalTotalEnrollments()
    {
        var table = $('#department-total-enrollments');

        blockUI();

        $.ajax({
            type: "GET",
            url: `${API_URL_ROOT}/index?call=courses&action=get_department_total_enrollments`,
            dataType: "json",
            contentType: "application/json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const enrollments = response.enrollments;
                    
                    table.DataTable({
                        oLanguage: {
                            oPaginate: { 
                                sPrevious: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-left"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>', "sNext": '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-right"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>' 
                            },
                            sInfo: "Showing _START_ to _END_ of _TOTAL_ entries",
                            sSearch: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>',
                            sSearchPlaceholder: "Search...",
                           sLengthMenu: "Results :  _MENU_",
                        },
                        lengthMenu: [7, 10, 20, 50, 100],
                        stripeClasses: [],
                        drawCallback: function () { $('.dataTables_paginate > .pagination').addClass(' pagination-style-13 pagination-bordered mb-5'); },
                        language: {
                            infoEmpty: "<span style='color:red'><b>No records found</b></span>"
                        },
                        processing: true,
                        serverSide: false,
                        destroy: true,
                        autoWidth: false,
                        pageLength: 100,
                        data: enrollments,
                        columns: [
                            {
                                data: '',
                                render: function (data, type, row, meta) 
                                {
                                    return meta.row + meta.settings._iDisplayStart + 1;
                                }
                            },
                            {data: 'DepartmentName'},
                            {data: 'TotalEnrollment'}
                        ]  
                    });

                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");
                }
            },
            error: function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.responseText, "error");
            }
        })
    }

    //load multi disciplinary students
    function loadMultiDisciplinaryStudents()
    {
        var table = $('#mutli-disciplinary-students');

        blockUI();

        $.ajax({
            type: "GET",
            url: `${API_URL_ROOT}/index?call=courses&action=get_multi_disciplinary_students`,
            dataType: "json",
            contentType: "application/json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const students = response.students;
                    
                    table.DataTable({
                        oLanguage: {
                            oPaginate: { 
                                sPrevious: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-left"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>', "sNext": '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-right"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>' 
                            },
                            sInfo: "Showing _START_ to _END_ of _TOTAL_ entries",
                            sSearch: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>',
                            sSearchPlaceholder: "Search...",
                           sLengthMenu: "Results :  _MENU_",
                        },
                        lengthMenu: [7, 10, 20, 50, 100],
                        stripeClasses: [],
                        drawCallback: function () { $('.dataTables_paginate > .pagination').addClass(' pagination-style-13 pagination-bordered mb-5'); },
                        language: {
                            infoEmpty: "<span style='color:red'><b>No records found</b></span>"
                        },
                        processing: true,
                        serverSide: false,
                        destroy: true,
                        autoWidth: false,
                        pageLength: 100,
                        data: students,
                        columns: [
                            {
                                data: '',
                                render: function (data, type, row, meta) 
                                {
                                    return meta.row + meta.settings._iDisplayStart + 1;
                                }
                            },
                            {data: 'firstName'},
                            {data: 'lastName'},
                            {data: 'email'}
                        ]  
                    });

                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");
                }
            },
            error: function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.responseText, "error");
            }
        })
    }

    //load grade distribution
    function loadGradeDistribution()
    {
        var table = $('#grade-distribution');

        blockUI();

        $.ajax({
            type: "GET",
            url: `${API_URL_ROOT}/index?call=courses&action=get_grade_distribution`,
            dataType: "json",
            contentType: "application/json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const grades = response.grades;
                    
                    table.DataTable({
                        oLanguage: {
                            oPaginate: { 
                                sPrevious: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-left"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>', "sNext": '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-right"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>' 
                            },
                            sInfo: "Showing _START_ to _END_ of _TOTAL_ entries",
                            sSearch: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>',
                            sSearchPlaceholder: "Search...",
                           sLengthMenu: "Results :  _MENU_",
                        },
                        lengthMenu: [7, 10, 20, 50, 100],
                        stripeClasses: [],
                        drawCallback: function () { $('.dataTables_paginate > .pagination').addClass(' pagination-style-13 pagination-bordered mb-5'); },
                        language: {
                            infoEmpty: "<span style='color:red'><b>No records found</b></span>"
                        },
                        processing: true,
                        serverSide: false,
                        destroy: true,
                        autoWidth: false,
                        pageLength: 100,
                        data: grades,
                        columns: [
                            {
                                data: '',
                                render: function (data, type, row, meta) 
                                {
                                    return meta.row + meta.settings._iDisplayStart + 1;
                                }
                            },
                            {data: 'departmentCode'},
                            {data: 'courseCode'},
                            {data: 'programName'},
                            {data: 'A_count'},
                            {data: 'B_count'},
                            {data: 'C_count'},
                            {data: 'D_count'},
                            {data: 'F_count'},
                            {data: 'total_count'},
                        ]  
                    });

                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");
                }
            },
            error: function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.responseText, "error");
            }
        })
    }

    //load career tags
    function loadCareerTags()
    {
        var table = $('#career-tags');

        blockUI();

        $.ajax({
            type: "GET",
            url: `${API_URL_ROOT}/index?call=career&action=get_career_tags`,
            dataType: "json",
            contentType: "application/json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const careerTags = response.careerTags;
                    
                    table.DataTable({
                        oLanguage: {
                            oPaginate: { 
                                sPrevious: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-left"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>', "sNext": '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-right"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>' 
                            },
                            sInfo: "Showing _START_ to _END_ of _TOTAL_ entries",
                            sSearch: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>',
                            sSearchPlaceholder: "Search...",
                           sLengthMenu: "Results :  _MENU_",
                        },
                        lengthMenu: [7, 10, 20, 50, 100],
                        stripeClasses: [],
                        drawCallback: function () { $('.dataTables_paginate > .pagination').addClass(' pagination-style-13 pagination-bordered mb-5'); },
                        language: {
                            infoEmpty: "<span style='color:red'><b>No records found</b></span>"
                        },
                        processing: true,
                        serverSide: false,
                        destroy: true,
                        autoWidth: false,
                        pageLength: 100,
                        data: careerTags,
                        columns: [
                            {
                                data: '',
                                render: function (data, type, row, meta) 
                                {
                                    return meta.row + meta.settings._iDisplayStart + 1;
                                }
                            },
                            {data: 'careerTitle'}
                        ]  
                    });

                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");
                }
            },
            error: function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.responseText, "error");
            }
        })
    }

    //load top careers
    function loadTopCareers()
    {
        var table = $('#top-careers');

        blockUI();

        $.ajax({
            type: "GET",
            url: `${API_URL_ROOT}/index?call=courses&action=get_top_careers`,
            dataType: "json",
            contentType: "application/json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const careers = response.careers;
                    
                    table.DataTable({
                        oLanguage: {
                            oPaginate: { 
                                sPrevious: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-left"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>', "sNext": '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-right"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>' 
                            },
                            sInfo: "Showing _START_ to _END_ of _TOTAL_ entries",
                            sSearch: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>',
                            sSearchPlaceholder: "Search...",
                           sLengthMenu: "Results :  _MENU_",
                        },
                        lengthMenu: [7, 10, 20, 50, 100],
                        stripeClasses: [],
                        drawCallback: function () { $('.dataTables_paginate > .pagination').addClass(' pagination-style-13 pagination-bordered mb-5'); },
                        language: {
                            infoEmpty: "<span style='color:red'><b>No records found</b></span>"
                        },
                        processing: true,
                        serverSide: false,
                        destroy: true,
                        autoWidth: false,
                        pageLength: 100,
                        data: careers,
                        columns: [
                            {
                                data: '',
                                render: function (data, type, row, meta) 
                                {
                                    return meta.row + meta.settings._iDisplayStart + 1;
                                }
                            },
                            {data: 'careerTitle'},
                            {data: 'NumRecommendations'},
                            {data: 'RecommendedCourses'}
                        ]  
                    });

                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");
                }
            },
            error: function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.responseText, "error");
            }
        })
    }

    //load programs
    function loadPrograms()
    {
        blockUI();

        $.ajax({
            type:'GET',
            url: `${API_URL_ROOT}/index?call=degreePrograms&action=get_degree_programs`,
            dataType: 'json',
            headers:{ 'x-access-token':token},
            success: function(response)
            {
                if(response.error == false)
                {
                    var programs = response.programs;
                    var html = '';

                    for(var i = 0; i < programs.length; i++)
                    {
                        html += `
                            <option value="${programs[i].programName}">${programs[i].programName}</option>
                        `
                    }

                    $("select.programName").append(html);
                    $('.selectpicker').selectpicker('refresh');
                    unblockUI();
                }
                else
                {
                    unblockUI();
                    showSimpleMessage("Attention", response.message, "error");       
                }
            },
            error:function(req, status, error)
            {
                unblockUI();
                showSimpleMessage("Attention", req.statusText, "error");
            }

        })
    }
}); 