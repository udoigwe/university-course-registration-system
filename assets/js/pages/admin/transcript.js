$(function () {

    'use strict';

    let token = sessionStorage.getItem('token');

    $(document).ready(function($) {

        loadDepartments();
        loadLevels();
        loadStudentsCGPA();
        print();

        $('#form-select-resultsheet').on("submit", function(e){
            e.preventDefault();

            var form = $(this);
            var departmentID = form.find('select.department_id').val();
            var levelID = form.find('select.level_id').val();
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

            loadStudentsCGPA(departmentID, levelID);
        });

        $('#cgpas').on('click', '.btn-print', function(){
            var userID = $(this).attr('data-id');
            var printModal = $('#printModal');

            blockUI();

            //fetch user details
            $.ajax({
                url: `${API_URL_ROOT}/transcripts/${userID}`,
                type: 'GET',
                dataType: 'json',
                headers:{'x-access-token':token},
                success: function(response)
                {
                    if(response.error == false)
                    {
                        var cgpa = response.cgpa;
                        var semesters = response.semesters;
                        var resultSheetsHTML = '';

                        printModal.find('.modal-title').text(`${cgpa.fullname}'s Transcript`);
                        printModal.find('.fullname').text(cgpa.fullname);
                        printModal.find('.reg_no').text(cgpa.reg_no);
                        printModal.find('.department').text(cgpa.department);
                        printModal.find('.level_code').text(cgpa.level_code);
                        printModal.find('.tqp').text(cgpa.TQP);
                        printModal.find('.tcu').text(cgpa.TCU);
                        printModal.find('.cgpa').text(cgpa.CGPA);
                        printModal.find('.status').html(`${cgpa.graduation_status == "Not Graduated" ? `<span class="badge badge-danger">Not Graduated</span>` : `<span class="badge badge-success">Graduated</span>`}`);

                        for(var i = 0; i < semesters.length; i++)
                        {
                            var semester = semesters[i];
                            var scores = semester.scores;
                            var serial = 0;
                            var scoresHTML = ``;

                            for(var x = 0; x < scores.length; x++)
                            {
                                var score = scores[x];

                                scoresHTML += `
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

                            resultSheetsHTML += `
                                <div class="row">
                                    <div class="col-12">
                                        <div class="modal-header">
                                            <span class="text-muted">
                                                Semester: <span class="strong">${semester.semester}</span>; 
                                                &nbsp;&nbsp;&nbsp;
                                                Session: <span class="strong">${semester.session}</span>; 
                                                &nbsp;&nbsp;&nbsp;
                                                Level: <span class="strong">${semester.gpa.level_code}</span>;
                                                &nbsp;&nbsp;&nbsp; 
                                                Department: <span class="strong">${semester.gpa.department}</span>; 
                                                &nbsp;&nbsp;&nbsp;
                                                TQP: <span class="strong">${semester.gpa.TQP || 0}</span>; 
                                                &nbsp;&nbsp;&nbsp;
                                                TCU: <span class="strong">${semester.gpa.TCU || 0}</span>;
                                                &nbsp;&nbsp;&nbsp;
                                                GPA: <span class="strong">${semester.gpa.GPA || 0}</span>;
                                                &nbsp;&nbsp;&nbsp;
                                            </span>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table mt-4 table-centered" id="item-list">
                                                <thead>
                                                    <tr>
                                                        <th class="strong">#</th>
                                                        <th class="strong">Course Title</th>
                                                        <th class="strong">Course Code</th>
                                                        <th class="strong">Course Type</th>
                                                        <th class="strong">Course Unit</th>
                                                        <th class="strong">CA Score</th>
                                                        <th class="strong">Exam Score</th>
                                                        <th class="strong">Total Score</th>
                                                        <th class="strong">Grade</th>
                                                        <th class="strong">Remarks</th>
                                                    </tr>
                                                </thead>
                                                <tbody>${scoresHTML}</tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            `

                            
                        }                            

                        printModal.find('.result-sheets').html(resultSheetsHTML);

                        unblockUI();
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
    });

    //load result Sheet
    function loadStudentsCGPA(departmentID = '', levelID = '')
    {
        var table = $('#cgpas');

        table.DataTable({
            dom: `<"row"<"col-md-12"<"row"<"col-md-4"l><"col-md-4"B><"col-md-4"f>>><"col-md-12"rt><"col-md-12"<"row"<"col-md-5"i><"col-md-7"p>>>>`,
            buttons: {
                buttons: [
                    { extend: 'copy', className: 'btn' },
                    { extend: 'csv', className: 'btn' },
                    { extend: 'excel', className: 'btn' },
                    { extend: 'print', className: 'btn' }
                ]
            },
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
            serverSide: true,
            destroy: true,
            autoWidth: false,
            pageLength: 100,
            ajax: {
                type: 'GET',
                url: `${API_URL_ROOT}/cgpas/data-table/fetch?department_id=${departmentID}&level_id=${levelID}`,
                dataType: 'json',
                headers:{'x-access-token':token},
                complete: function()
                {
                    //$("#loadingScreen").hide();
                    //$('.panel-refresh').click();
                },
                async: true,
                error: function(xhr, error, code)
                {
                    console.log(xhr);
                    console.log(code);
                }
            },
            columnDefs: [
                { orderable: false, targets: [1, 2, 3, 4, 5, 6, 7] }
            ],
            order: [[0, "desc"]],
            columns: [
                {
                    data: 'user_id',
                    render: function (data, type, row, meta) 
                    {
                        return meta.row + meta.settings._iDisplayStart + 1;
                    }
                },
                {data: 'fullname'},
                {data: 'reg_no'},
                {data: 'department'},
                {data: 'level_code'},
                {
                    data: 'graduation_status',
                    render:function(data, type, row, meta)
                    {
                        var graduationStatus = data == "Not Graduated" ? `<span class="badge badge-danger"> `+data+` </span>` : data == "Graduated" ? `<span class="badge badge-success"> `+data+` </span>` : null;
                        return graduationStatus;
                    }
                },
                {
                    data: 'CGPA',
                    render:function(data, type, row, meta)
                    {
                        return data.toFixed(2)
                    }
                },
                {
                    data: 'user_id',
                    render: function(data, type, row, meta)
                    {
                        var actions =  `
                            <a href="javascript:void(0);" class="btn btn-link font-18 text-muted btn-sm  btn-print" title="Print Result Details" data-toggle="modal" data-target="#printModal" data-id="${data}">
                                <i class="mdi mdi-printer"></i>
                            </a>
                        `;

                        return actions;
                    },
                    searchable: false,
                    sortable: false
                }
            ]  
        });
    }

    //load departments
    function loadDepartments()
    {
        blockUI();

        $.ajax({
            type:'GET',
            url: `${API_URL_ROOT}/departments?department_status=Active`,
            dataType: 'json',
            headers:{ 'x-access-token':token},
            success: function(response)
            {
                if(response.error == false)
                {
                    var departments = response.result.departments;
                    var html = '';

                    for(var i = 0; i < departments.length; i++)
                    {
                        html += `
                            <option value="${departments[i].department_id}">${departments[i].department}</option>
                        `
                    }

                    $("select.department_id").append(html);
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
                showSimpleMessage("Attention", "ERROR - "+req.status+" : "+req.statusText, "error");
            }

        })
    }

    //load levels
    function loadLevels()
    {
        blockUI();

        $.ajax({
            type:'GET',
            url: `${API_URL_ROOT}/levels?level_status=Active`,
            dataType: 'json',
            headers:{ 'x-access-token':token},
            success: function(response)
            {
                if(response.error == false)
                {
                    var levels = response.result.levels;
                    var html = '';

                    for(var i = 0; i < levels.length; i++)
                    {
                        html += `
                            <option value="${levels[i].level_id}">${levels[i].level_code}</option>
                        `
                    }

                    $("select.level_id").append(html);
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
                showSimpleMessage("Attention", "ERROR - "+req.status+" : "+req.statusText, "error");
            }

        })
    }

    function print()
    {
        $('#printModal').on("click", ".btn-print", function () {

            const content = $(".content");

            const printArea = $("#printModal .print-area").detach();
            const containerFluid = $(".container-fluid").detach();

            content.append(printArea);

            const backdrop = $('body .modal-backdrop').detach()
            $('.modal-backdrop').remove();

            window.print();

            content.empty();
            content.append(containerFluid);

            $("#printModal .modal-body").append(printArea);

            $('body').append(backdrop);
        });
    }
}); 