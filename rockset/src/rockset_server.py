import flask
import logging
import os
import socket

app = flask.Flask("rockset_interview")

def getResponse():
    pod = "Not running in a pod"
    try:
        # Checked this in some empty pods
        pod = os.environ.get("POD_NAME", socket.gethostname())
    except Exception:
        pass
    node_name = os.environ.get("NODE_NAME", "Not running in a pod")
    namespace = os.environ.get("NODE_NAMESPACE", "Not running in a pod")
    ip_addr = os.environ.get("POD_IP", flask.request.host.split(':')[0])

    return "".join([
        "Pod: {}\n".format(pod),
        "Node: {}\n".format(node_name),
        "Namespace: {}\n".format(namespace),
        "IP: {}\n".format(ip_addr),
    ])

@app.route('/', methods=['GET'])
def home():
    response = flask.make_response(getResponse())
    response.headers["content-type"] = "text/plain"
    return response


def run():
    port = int(os.environ.get("SERVER_PORT", 80))
    logging.basicConfig(filename='demo.log', level=logging.DEBUG)

    #0.0.0.0 is required for later Docker/k8s compatibility
    app.run(host="0.0.0.0", port=port)


def main():
    run()

if __name__ == "__main__":
    main()
