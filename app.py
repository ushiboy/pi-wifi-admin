import os
import subprocess
import tornado.ioloop
import tornado.web


class SystemControl(object):

    def read_wpa_supplicant_conf(self, config_path):
        with open(config_path) as f:
            return f.read()

    def write_wpa_supplicant_conf(self, config_path, data):
        subprocess.check_call('sudo sh -c "echo -n \'%s\' > %s"' % (data, config_path) , shell=True)

    def auto_start_off(self):
        subprocess.run('sudo sed -i --follow-symlinks s/AUTO_START=ON/AUTO_START=OFF/g /etc/default/pi-wifi-admin', shell=True)

    def reboot(self):
        subprocess.run('sudo reboot', shell=True)


class MainHandler(tornado.web.RequestHandler):

    def initialize(self, sys_ctrl, wpa_supplicant_conf_path):
        self._sys_ctrl = sys_ctrl
        self._wpa_supplicant_conf_path = wpa_supplicant_conf_path

    def get(self):
        html = """<html>
  <head><title>Wifi Setting</title></head>
  <body>
    <form method='POST' action='/'>
      <textarea name='config' style='width:800px;height:600px;'>%s</textarea>
      <input type='submit' value='Save' />
    </form>
  </body>
</html>
"""
        conf = self._sys_ctrl.read_wpa_supplicant_conf(self._wpa_supplicant_conf_path)
        self.write(html % conf)
        self.set_status(200)

    def post(self):
        conf = self.get_body_argument('config')
        self._sys_ctrl.write_wpa_supplicant_conf(self._wpa_supplicant_conf_path, conf.replace('\r', '').replace('"', '\\"'))
        self._sys_ctrl.auto_start_off()
        self._sys_ctrl.reboot()
        self.redirect('/', permanent=True)

def make_app(sys_ctrl, wpa_supplicant_conf_path):
    return tornado.web.Application([
        (r'/', MainHandler, {
            'sys_ctrl': sys_ctrl,
            'wpa_supplicant_conf_path': wpa_supplicant_conf_path
            })
    ])

if __name__ == '__main__':
    try:
        port = int(os.getenv('PORT', '8080'))
        sys_ctrl = SystemControl()
        app = make_app(sys_ctrl, '/etc/wpa_supplicant/wpa_supplicant.conf')
        app.listen(port, '0.0.0.0')
        tornado.ioloop.IOLoop.instance().start()
    except KeyboardInterrupt:
        pass
