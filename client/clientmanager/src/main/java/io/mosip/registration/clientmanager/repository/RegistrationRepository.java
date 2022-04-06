package io.mosip.registration.clientmanager.repository;

import io.mosip.registration.clientmanager.constant.PacketClientStatus;
import io.mosip.registration.clientmanager.dao.RegistrationDao;
import io.mosip.registration.clientmanager.entity.Registration;

import javax.inject.Inject;
import java.util.List;

public class RegistrationRepository {

    private RegistrationDao registrationDao;

    @Inject
    public RegistrationRepository(RegistrationDao registrationDao) {
        this.registrationDao = registrationDao;
    }

    public List<Registration> getAllRegistrations() {
        return this.registrationDao.findAll();
    }

    public Registration getRegistration(String packetId) {
        return this.registrationDao.findOneByPacketId(packetId);
    }

    public void updateServerStatus(String packetId, String serverStatus) {
        this.registrationDao.updateServerStatus(packetId, serverStatus);
    }

    public Registration insertRegistration(String packetId, String containerPath) {
        Registration registration = new Registration(packetId);
        registration.setFilePath(containerPath);
        registration.setRegType("NEW");
        registration.setCenterId("10001");
        registration.setClientStatus(PacketClientStatus.CREATED.name());
        registration.setServerStatus(null);
        registration.setCrDtime(System.currentTimeMillis());
        registration.setCrBy("110006");
        this.registrationDao.insert(registration);
        return registration;
    }
}