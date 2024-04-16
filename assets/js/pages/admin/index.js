$(function () {

    'use strict';

    let token = sessionStorage.getItem('token');

    $(document).ready(function($) {

        loadDashboard();
    });

    function loadDashboard()
    {
        blockUI();

        $.ajax({
            url: `${API_URL_ROOT}/index?call=dashboard&action=get_dashboard`,
            type: "GET",
            dataType: "json",
            success: function(response)
            {
                if(response.error === false)
                {
                    const dashboard = response.dashboard;
                    $('.faculty-count').html(dashboard.program_count)
                    $('.department-count').html(dashboard.department_count)
                    $('.course-count').html(dashboard.course_count)
                    $('.student-count').html(dashboard.student_count)
                    $('.acad-staff-count').html(dashboard.instructor_count)

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
                showSimpleMessage("Attention", req.statusText, "error");
            }
        })
    }
}); 