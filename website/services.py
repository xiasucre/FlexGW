# -*- coding: utf-8 -*-
"""
    website.services
    ~~~~~~~~~~~~~~~~

    top level services api.
"""


import subprocess
from flask import current_app

from threading import Timer


def exec_command(cmd, timeout=5, stdout=subprocess.PIPE):
    current_app.logger.info("执行命令 => {}".format(cmd))
    proc = subprocess.Popen(cmd, stdout=stdout,
                            stderr=subprocess.PIPE)
    # settings exec timeout
    timer = Timer(timeout, proc.kill)
    timer.start()
    stdout, stderr = proc.communicate()
    timer.cancel()
    current_app.logger.info("命令结果 => {}".format({'return_code': proc.returncode, 'stdout': stdout,
            'stderr': stderr}))
    return {'return_code': proc.returncode, 'stdout': stdout,
            'stderr': stderr}
