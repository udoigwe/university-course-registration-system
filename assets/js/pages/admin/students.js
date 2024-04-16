$(function () {

    'use strict';

    let token = sessionStorage.getItem('token');

    $(document).ready(function($) {
        loadStudents();
        loadStudents2();
        loadPrograms();

        //submit new students
        $('#form-new-student').on("submit", function(e){
            e.preventDefault();
            newStudent();
        });
        
        //update students
        $('#form-update-student').on("submit", function(e){
            e.preventDefault();
            updateStudent();
        });
        
        //fetch student gpa
        $('#gpa-form').on("submit", function(e){
            e.preventDefault();
            getStudentGPA();
        });
        
        //fetch student transcript
        $('#transcript-form').on("submit", function(e){
            e.preventDefault();
            getStudentTranscript();
        });

        //load single student
        $('#students').on('click', '.btn-edit', function(){
            var studentID = $(this).attr('data-id');
            var editModal = $('#editModal');
            
            $.ajax({
                url: `${API_URL_ROOT}/index?call=users&action=get_student&studentID=${studentID}`,
                type: 'GET',
                dataType: 'json',
                success: function(response)
                {
                    if(response.error == false)
                    {
                        var student = response.student;

                        editModal.find('.modal-title').text(`${student.firstName} ${student.lastName}`);
                        editModal.find('.firstName').val(student.firstName);
                        editModal.find('.lastName').val(student.lastName);
                        editModal.find('.email').val(student.email);
                        editModal.find('.phoneNumber').val(student.phoneNumber);
                        editModal.find('select.gender').selectpicker('val', student.gender);
                        editModal.find('select.programID').selectpicker('val', student.programID);
                        editModal.find('select.classification').selectpicker('val', student.classification);
                        editModal.find('.studentID').val(student.studentID);
                    }
                    else
                    {
                        showSimpleMessage("Attention", response.message, "error");   
                    }
                },
                error: function(req, status, error)
                {
                    showSimpleMessage("Attention", "ERROR - "+req.status+" : "+req.statusText, "error");
                }
            });
        });

        //delete single student
        $('#students').on('click', '.btn-delete', function(){
            var studentID = $(this).attr('data-id');
            deleteStudent(studentID);
        });

    });

    //internal function to add new student
    function newStudent() 
    {
        swal({
            title: "Attention",
            text: "Are you sure you want to create a new student?",
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
                var form = $('#form-new-student'); //form
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
                    url: `${API_URL_ROOT}/index?call=users&action=create_new_student`,
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
                            loadStudents();
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

    //internal function to update student
    function updateStudent() 
    {
        swal({
            title: "Attention",
            text: "Are you sure you want to update this student?",
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
                var form = $('#form-update-student'); //form
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
                    url: `${API_URL_ROOT}/index?call=users&action=update_student`,
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
                            $('#editModal').modal("hide");
                            loadStudents();
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

    //internal function to fetch student GPA
    function getStudentGPA() 
    {
        //name vairables
        var form = $('#gpa-form'); //form
        var studentID = form.find("select.studentID").val();
        var studentName = form.find("select.studentID").find("option:selected").text();
        var gpaModal = $('#gpaModal');
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
            type: 'GET',
            url: `${API_URL_ROOT}/index?call=users&action=get_student_gpa&studentID=${studentID}`,
            dataType: 'json',
            success: function(response)
            {
                if(response.error == false)
                {
                    var GPA = response.gpa;
                    gpaModal.find(".modal-title").text(studentName);
                    gpaModal.find(".gpa-div").html(GPA);
                    gpaModal.modal('show');
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
        }); 
    }
    
    //internal function to fetch student transcript
    function getStudentTranscript() 
    {
        //name vairables
        var form = $('#transcript-form'); //form
        var studentID = form.find("select.studentID").val();
        var fields = form.find('input.required, select.required');
        var table = $('#transcript');
        
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
            type: "GET",
            url: `${API_URL_ROOT}/index?call=users&action=get_student_transcript&studentID=${studentID}`,
            dataType: "json",
            contentType: "application/json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const transcript = response.transcript;
                    
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
                        data: transcript,
                        columns: [
                            {
                                data: '',
                                render: function (data, type, row, meta) 
                                {
                                    return meta.row + meta.settings._iDisplayStart + 1;
                                }
                            },
                            {data: 'studentID'},
                            {data: 'firstName'},
                            {data: 'lastName'},
                            {data: 'classification'},
                            {data: 'courseTitle'},
                            {data: 'creditUnit'},
                            {data: 'finalGrade'},
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

    //load students
    function loadStudents2()
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
    
    //load students
    function loadStudents()
    {
        var table = $('#students');

        blockUI();

        $.ajax({
            type: "GET",
            url: `${API_URL_ROOT}/index?call=users&action=get_students`,
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
                            {data: 'email'},
                            {data: 'phoneNumber'},
                            {data: 'gender'},
                            {data: 'programName'},
                            {data: 'classification'},
                            {
                                data: 'studentID',
                                render: function(data, type, row, meta)
                                {
                                    var actions = `
                                        <a href="javascript:void(0);" class="btn btn-link font-18 text-muted btn-sm btn-edit" title="Edit Student" data-id="${data}" data-toggle="modal" data-target="#editModal" data-animation="fall" data-plugin="custommodal" data-overlayColor="#012"><i class="mdi mdi-pencil"></i>
                                        </a>
                                        <a href="javascript:void(0);" class="btn btn-link font-18 text-muted btn-sm btn-delete" title="Delete Student" data-id="${data}"><i class="mdi mdi-close"></i>
                                        </a>
                                    `;

                                    return actions;
                                },
                                searchable: false,
                                sortable: false
                            },
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
                    var html2 = '';

                    for(var i = 0; i < programs.length; i++)
                    {
                        html += `
                            <option value="${programs[i].programName}">${programs[i].programName}</option>
                        `
                        html2 += `
                            <option value="${programs[i].programID}">${programs[i].programName}</option>
                        `
                    }

                    $("select.programName").append(html);
                    $("select.programID").append(html2);
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

    //internal function to delete a student
    function deleteStudent(studentID) 
    {
        swal({
            title: "Attention",
            text: "Are you sure you want to delete this student?",
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

                blockUI();        

                $.ajax({
                    type: 'GET',
                    url: `${API_URL_ROOT}/index?call=users&action=delete_student&studentID=${studentID}`,
                    dataType: 'json',
                    success: function(response)
                    {
                        if(response.error == false)
                        {
                            unblockUI();
                            showSimpleMessage("Success", response.message, "success");
                            loadStudents();
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
                        showSimpleMessage("Attention", "ERROR - "+req.status+" : "+req.statusText, "error");
                    }
                });
            } 
            else 
            {
                showSimpleMessage('Canceled', 'Process Abborted', 'error');
            }
        });
    }
}); 