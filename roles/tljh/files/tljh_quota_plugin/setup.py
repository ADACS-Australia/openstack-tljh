from setuptools import setup

setup(
    name="tljh-quota-plugin",
    author="David Liptai",
    entry_points={"tljh": ["quota_plugin = tljh_quota_plugin"]},
    py_modules=["tljh_quota_plugin"],
)
